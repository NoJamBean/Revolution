#apt install python3.12-venv
#python3 -m venv .venv
#source .venv/bin/activate // or select kernel venv in visual studio code
#pip install ipykernel requests aws-requests-auth opensearch-py pandas

import subprocess
import json
import sys
import os
import base64    
import binascii 
import requests

def decode_base64_string(encoded_str):
    try:
        encoded_bytes = encoded_str.encode('ascii')
        decoded_bytes = base64.b64decode(encoded_bytes)
        decoded_string = decoded_bytes.decode('utf-8')
        return decoded_string
    except (binascii.Error, TypeError, ValueError) as e:
        print(f"오류: Base64 디코딩 실패 - {e}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"오류: Base64 디코딩 중 알 수 없는 오류 발생 - {e}", file=sys.stderr)
        return None

def get_terraform_outputs(output_names):
    outputs = {}
    try:
        command = ['terraform', 'output', '-json']
        process = subprocess.run(command, capture_output=True, text=True, check=True, encoding='utf-8')

        all_outputs = json.loads(process.stdout)

        if not output_names:
            return all_outputs 
        else:
            for name in output_names:
                if name in all_outputs:
                    outputs[name] = all_outputs[name].get('value', None)
                else:
                    print(f"경고: 출력 값 '{name}'을 찾을 수 없습니다.", file=sys.stderr)
                    outputs[name] = None
            return outputs

    except FileNotFoundError:
        print("오류: 'terraform' 명령어를 찾을 수 없습니다. Terraform이 설치되어 있고 PATH에 있는지 확인하세요.", file=sys.stderr)
        return None
    except subprocess.CalledProcessError as e:
        print(f"오류: 'terraform output' 실행 중 오류 발생 (종료 코드: {e.returncode})", file=sys.stderr)
        print(f"오류 메시지: {e.stderr}", file=sys.stderr)
        return None
    except json.JSONDecodeError as e:
        print(f"오류: Terraform 출력 JSON 파싱 중 오류 발생: {e}", file=sys.stderr)
        print(f"받은 출력: {process.stdout}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"알 수 없는 오류 발생: {e}", file=sys.stderr)
        return None


def create_opensearch_index_template(pattern_title):
    api_path = f"_index_template/web_logs_template"
    url = f"https://{opensearch_endpoint}/{api_path}"
    headers = {
        "Content-Type": "application/json",
        "osd-xsrf": "true"
    }
    payload = {
    "index_patterns": ["web-*"],
    "template": {
        "settings": {
            "number_of_shards": 1,
            "index.default_pipeline": "parse_querystring_final"
        },
        "mappings": {
        "properties": {
            "eventTime": { "type": "date" },
            "sourceIPAddress": { "type": "ip" },
            "geoip": {
            "properties": {
                "country_iso_code": { "type": "keyword" },
                "country_name": { "type": "keyword" },
                "subdivision_name": { "type": "keyword" },
                "city_name": { "type": "keyword" },
                "postal_code": { "type": "keyword" },
                "location": { "type": "geo_point" }
            }
            },
            "requestParameters": {
            "properties": {
                "statusCode": { "type": "integer" },
                "httpMethod": { "type": "keyword" },
                "requestPath": { "type": "keyword" },
                "queryString": {
                    "type": "text",
                    "fielddata": True
                }
            }
            }
        }
        }
    },
    "priority": 1000
    }
    print(f"\n인덱스 템플릿 '{pattern_title}' 생성을 시도합니다...")
    print(f"대상 URL: {url}")
    try:
        response = requests.put(
            url,
            auth=(OPENSEARCH_ADMIN_USER, OPENSEARCH_ADMIN_PASSWORD),
            headers=headers,
            json=payload,
            timeout=30
        )
        response.raise_for_status() 
        print(f"성공! 응답 코드: {response.status_code}")
        response_json = response.json()
        return response_json
    except Exception as e:
        print(f"알 수 없는 오류 발생: {e}")
        return None

def create_or_update_ingest_pipeline(pipeline_name):
    print(f"인제스트 파이프라인 '{pipeline_name}' 생성을 시도합니다...")
    api_path = f"_ingest/pipeline/{pipeline_name}"
    url = f"https://{opensearch_endpoint}/{api_path}"
    headers = {
        "Content-Type": "application/json",
        "osd-xsrf": "true"
    }
    pipeline_body = {
        "description": "requestParameters.queryString 필드를 파싱 url.query_params.* 필드로 저장",
        "processors": [
        {
        "kv": {
            "field": "requestParameters.queryString",
            "field_split": "&",
            "value_split": "=",
            "target_field": "temp.kv_results", 
            "ignore_missing": True,
            "ignore_failure": True
        }
        },
        {
        "json": {
            "field": "requestParameters.queryString",
            "target_field": "temp.json_results", 
            "if": "ctx.requestParameters?.queryString != null && ctx.requestParameters.queryString.startsWith('{') && ctx.requestParameters.queryString.endsWith('}')",
            "add_to_root": False,
            "ignore_failure": True
        }
        },
        {
        "script": {
            "lang": "painless",
            "source": """
            if (!ctx.containsKey('url')) {
                ctx['url'] = [:];
            }
            ctx.url['query_params'] = [:];

            boolean populated = false;
            if (ctx.containsKey('temp') && ctx.temp.containsKey('kv_results') && ctx.temp.kv_results instanceof Map && !ctx.temp.kv_results.isEmpty()) {
                for (entry in ctx.temp.kv_results.entrySet()) {
                if (entry.getValue() != null) {
                    if (!(entry.getValue() instanceof String) || !entry.getValue().isEmpty()) {
                    ctx.url.query_params[entry.getKey()] = entry.getValue();
                    populated = true;
                    }
                }
                }
            }
            else if (ctx.containsKey('temp') && ctx.temp.containsKey('json_results') && ctx.temp.json_results instanceof Map && !ctx.temp.json_results.isEmpty()) {
                for (entry in ctx.temp.json_results.entrySet()) {
                if (entry.getValue() != null) {
                    if (!(entry.getValue() instanceof String) || !entry.getValue().isEmpty()) {
                    ctx.url.query_params[entry.getKey()] = entry.getValue();
                    populated = true;
                    }
                }
                }
            }
            if (!populated) {
                ctx.remove('url');
            }
            """,
            "ignore_failure": False
        }
        },
        {
        "remove": {
            "field": "temp",
            "ignore_missing": True,
            "ignore_failure": True
        }
        }
    ]
    }
    try:
        response = requests.put(
            url,
            auth=(OPENSEARCH_ADMIN_USER, OPENSEARCH_ADMIN_PASSWORD),
            headers=headers,
            json=pipeline_body,
            timeout=30
        )
        response.raise_for_status() 
        print(f"성공! 응답 코드: {response.status_code}")
        response_json = response.json()
        return response_json
    except requests.exceptions.HTTPError as http_err:
        print(f"HTTP 오류 발생: {http_err}")
        print(f"응답 내용: {response.text}")
        return None
    except Exception as e:
        print(f"알 수 없는 오류 발생: {e}")
        return None


def create_opensearch_index_template(template_name, payload):
    api_path = f"_index_template/{template_name}"
    if not opensearch_endpoint.startswith(('http://', 'https://')):
        url = f"https://{opensearch_endpoint}/{api_path}"
    else:
        url = f"{opensearch_endpoint}/{api_path}"

    headers = {
        "Content-Type": "application/json",
        "osd-xsrf": "true"
    }

    print(f"\n인덱스 템플릿 '{template_name}' 생성을 시도합니다...")
    print(f"대상 URL: {url}")

    try:
        response = requests.put(
            url,
            auth=(OPENSEARCH_ADMIN_USER, OPENSEARCH_ADMIN_PASSWORD),
            headers=headers,
            json=payload,
            timeout=30,
        )
        response.raise_for_status()
        print(f"성공! 응답 코드: {response.status_code}")
        response_json = response.json()
        return response_json
    except requests.exceptions.HTTPError as http_err:
        print(f"HTTP 오류 발생: {http_err}")
        try:
            print(f"오류 응답 내용: {response.text}")
        except:
            pass
        return None
    except requests.exceptions.ConnectionError as conn_err:
        print(f"연결 오류 발생: {conn_err}")
        return None
    except requests.exceptions.Timeout as timeout_err:
        print(f"타임아웃 오류 발생: {timeout_err}")
        return None
    except Exception as e:
        print(f"알 수 없는 오류 발생: {e}")
        return None

if __name__ == "__main__":
    desired_outputs = ["opensearch_domain_endpoint", "lambda_iam_role_arn","firehose_iam_role_arn"]
    retrieved_outputs = get_terraform_outputs(desired_outputs)

    if retrieved_outputs:
        print("\n성공적으로 가져온 Terraform 출력 값:")
        for name, value in retrieved_outputs.items():
            print(f"- {name}: {value}")
        opensearch_endpoint = retrieved_outputs.get("opensearch_domain_endpoint")
        lambda_iam_role_arn = retrieved_outputs.get("lambda_iam_role_arn")
        firehose_iam_role_arn = retrieved_outputs.get("firehose_iam_role_arn")
        TARGET_OPENSEARCH_ROLE = "all_access"
        OPENSEARCH_ADMIN_USER = decode_base64_string("YWRtaW4=")
        OPENSEARCH_ADMIN_PASSWORD = decode_base64_string("MGwwM2xWJDNAbDJrcmw=")
        if opensearch_endpoint and lambda_iam_role_arn:
            print("\n스크립트의 다른 부분에서 값 사용 가능:")
            print(f"  OpenSearch Endpoint: {opensearch_endpoint}")
            print(f"  Lambda Role ARN: {lambda_iam_role_arn}")
            print(f"  Firehose Role ARN: {firehose_iam_role_arn}")
        else:
            print("\n필요한 출력 값 중 일부를 가져오지 못했습니다.")
    else:
        print("\nTerraform 출력 값을 가져오는 데 실패했습니다.")

    target_pipeline_name = "parse_querystring_final"
    result = create_or_update_ingest_pipeline(
        pipeline_name=target_pipeline_name,
    )
    INDEX_PATTERN_TITLE = ["web-*"]
    for index_pattern in INDEX_PATTERN_TITLE:
        result = create_opensearch_index_template(
            pattern_title=index_pattern,
        )
        if result:
            print("\n함수 호출 성공.")
        else:
            print("\n함수 호출 실패.")

    cloudtrail_template_name = "cloudtrail_logs_template" 
    cloudtrail_payload = {
        "index_patterns": ["cloudtrail-*"], 
        "template": {
            "settings": {
                "number_of_shards": 1,
                "number_of_replicas": 1 
            },
            "mappings": {
                "properties": {
                    "eventTime": {"type": "date"},
                    "eventVersion": {"type": "keyword"},
                    "userIdentity": {
                        "properties": {
                            "type": {"type": "keyword"},
                            "principalId": {"type": "keyword"},
                            "arn": {"type": "keyword"},
                            "accountId": {"type": "keyword"},
                            "invokedBy": {"type": "keyword"},
                            "accessKeyId": {"type": "keyword"},
                            "userName": {"type": "keyword"},
                            "sessionContext": {
                                "properties": {
                                    "attributes": {
                                        "properties": {
                                            "mfaAuthenticated": {"type": "boolean"},
                                            "creationDate": {"type": "date"}
                                        }
                                    },
                                    "sessionIssuer": {
                                         "properties": {
                                             "type": {"type": "keyword"},
                                             "principalId": {"type": "keyword"},
                                             "arn": {"type": "keyword"},
                                             "accountId": {"type": "keyword"},
                                             "userName": {"type": "keyword"}
                                         }
                                    }
                                }
                            },
                            "webIdFederationData": {
                                "properties": {
                                    "federatedProvider": {"type": "keyword"},
                                    "attributes": {"type": "object", "enabled": False} # 하위 필드 인덱싱 안 함
                                }
                            }
                        }
                    },
                    "eventSource": {"type": "keyword"},
                    "eventName": {"type": "keyword"},
                    "awsRegion": {"type": "keyword"},
                    "sourceIPAddress": {"type": "ip"},
                    "userAgent": {"type": "text", "fields": {"keyword": {"type": "keyword", "ignore_above": 256}}},
                    "errorCode": {"type": "keyword"},
                    "errorMessage": {"type": "text"},
                    "requestParameters": {"type": "object", "dynamic": True}, # 또는 "flattened"
                    "responseElements": {"type": "object", "dynamic": True}, # 또는 "flattened"
                    "additionalEventData": {"type": "object", "dynamic": True},
                    "requestID": {"type": "keyword"},
                    "eventID": {"type": "keyword"},
                    "readOnly": {"type": "boolean"},
                    "resources": {
                         "type": "object", "dynamic": True
                    },
                    "eventType": {"type": "keyword"},
                    "apiVersion": {"type": "keyword"},
                    "managementEvent": {"type": "boolean"},
                    "recipientAccountId": {"type": "keyword"},
                    "serviceEventDetails": {"type": "object", "dynamic": True},
                    "sharedEventID": {"type": "keyword"},
                    "eventCategory": {"type": "keyword"},
                    "vpcEndpointId": {"type": "keyword"},
                    "geoip": {
                        "properties": {
                            "country_iso_code": { "type": "keyword" },
                            "country_name": { "type": "keyword" },
                            "region_name": { "type": "keyword" },
                            "city_name": { "type": "keyword" },
                            "location": { "type": "geo_point" }
                        }
                    }
                }
            }
        },
        "priority": 500, 

    }

    result = create_opensearch_index_template(
        template_name=cloudtrail_template_name,
        payload=cloudtrail_payload
    )

    if result:
        print(f"\n'{cloudtrail_template_name}' 템플릿 생성/업데이트 성공.")
        print(f"응답 내용: {json.dumps(result, indent=2)}")
    else:
        print(f"\n'{cloudtrail_template_name}' 템플릿 생성/업데이트 실패.")
    print(f"\n사용할 값 확인:")
    print(f"  OpenSearch Endpoint: {opensearch_endpoint}")
    print(f"  Lambda Role ARN: {lambda_iam_role_arn}")
    print(f"  Firehose Role ARN: {firehose_iam_role_arn}")
    print(f"  Target OpenSearch Role: {TARGET_OPENSEARCH_ROLE}")
    print(f"  Admin User: {OPENSEARCH_ADMIN_USER}")

    if not OPENSEARCH_ADMIN_PASSWORD:
        print("\n오류: OpenSearch 관리자 비밀번호가 설정되지 않았습니다. OPENSEARCH_ADMIN_PASSWORD 환경 변수를 설정하세요.", file=sys.stderr)
        sys.exit(1)

    api_path = f"_plugins/_security/api/rolesmapping/{TARGET_OPENSEARCH_ROLE}"
    url = f"https://{opensearch_endpoint}/{api_path}"
    headers = {"Content-Type": "application/json"}
    payload = {
        "backend_roles": [
            lambda_iam_role_arn,
            firehose_iam_role_arn
        ],
        "hosts": [],
        "users": [
            OPENSEARCH_ADMIN_USER
        ]
    }
    print(f"\n'{TARGET_OPENSEARCH_ROLE}' 역할에 IAM 역할 '{lambda_iam_role_arn}' 매핑을 시도합니다...")
    print(f"대상 URL: {url}")
    try:
        response = requests.put(
            url,
            auth=(OPENSEARCH_ADMIN_USER, OPENSEARCH_ADMIN_PASSWORD),
            headers=headers,
            json=payload,
            timeout=30
        )
        response.raise_for_status() 
        print(f"성공! 응답 코드: {response.status_code}")
        print("응답 내용:")
        print(json.dumps(response.json(), indent=2))

    except requests.exceptions.RequestException as e:
        print(f"오류 발생: {e}")
        if e.response is not None:
            print(f"오류 응답 코드: {e.response.status_code}")
            try:
                print(f"오류 응답 내용: {json.dumps(e.response.json(), indent=2)}")
            except json.JSONDecodeError:
                print(f"오류 응답 내용 (Non-JSON): {e.response.text}")
    except Exception as e:
        print(f"알 수 없는 오류 발생: {e}")