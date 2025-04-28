using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace MyApi.Data
{
    public class UserDbContext : DbContext
    {
        public UserDbContext(DbContextOptions<UserDbContext> options) : base(options) { }

        // 예시: User 테이블 관리
        public DbSet<User> Users { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // 사용자 테이블 설정
            modelBuilder.Entity<User>().HasKey(u => u.Id);
        }
    }

    public class UserReadDbContext : DbContext
    {
        public UserReadDbContext(DbContextOptions<UserReadDbContext> options) : base(options) { }

        public DbSet<User> Users { get; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>().HasKey(u => u.Id);
        }
    } 

    [Table("userTBL")]
    public class User
    {
        [Key]
        [Column("id")]
        [Required]
        [StringLength(10)]
        public string? Id { get; set; }
        
        [Column("nickname")]
        [StringLength(30)]
        public string? Nickname { get; set; }

        [Required]
        [Column("password")]
        [StringLength(60)]
        public string? Password { get; set; }

        [Required]
        [Column("e_mail")]
        [StringLength(320)]
        public string? Email { get; set; }

        [Column("phone_number")]
        [StringLength(20)]
        public string? PhoneNumber { get; set; }

        [Column("balance")]
        [Range(0, long.MaxValue)]
        public long Balance { get; set; } = 0;

        [Column("modified_date")]
        public DateTime ModifiedDate { get; set; } = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("Asia/Seoul"));

        public User() {}
    }

    public class ResendRequest
    {
        public string Id { get; set; }
    }

    public class ConfirmRequest
    {
        public string Id { get; set; }
        public string Code { get; set; }
    }

    public class LoginRequest
    {
        public string Id { get; set; }
        public string Password { get; set; }
    }
}