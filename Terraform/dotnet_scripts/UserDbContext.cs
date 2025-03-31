using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

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
            modelBuilder.Entity<User>()
                .HasKey(u => u.Id);
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

        [Required]
        [Column("password")]
        [StringLength(60)]
        public string? Password { get; set; }

        [Required]
        [Column("phone_number")]
        [StringLength(10)]
        public string? PhoneNumber { get; set; }

        [Column("balance")]
        [Range(0, long.MaxValue)]
        public long Balance { get; set; } = 0;

        [Column("modified_date")]
        public DateTime ModifiedDate { get; set; } = DateTime.UtcNow;

        public User() {}
    }
}