variable "zone" {
  type = map(string)
  default = {
    a = "ap-northeast-2a",
    c = "ap-northeast-2c"
  }
}