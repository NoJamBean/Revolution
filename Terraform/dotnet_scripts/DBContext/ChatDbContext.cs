using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyApi.Data
{
    public class ChatDbContext : DbContext
    {
        public ChatDbContext(DbContextOptions<ChatDbContext> options) : base(options) { }
        
        public DbSet<Room> Rooms { get; set; } = null!;
        public DbSet<Message> Messages { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Room>().HasKey(r => r.RoomId);

            modelBuilder.Entity<Message>().HasKey(m => new { m.RoomId, m.Id, m.Time }); // 복합 PK

            modelBuilder.Entity<Message>()
                .HasOne<Room>()
                .WithMany()
                .HasForeignKey(m => m.RoomId)
                .OnDelete(DeleteBehavior.Cascade); // 방 삭제시 메시지 자동 삭제
        }
    }

    public class ChatReadDbContext : DbContext
    {
        public ChatReadDbContext(DbContextOptions<ChatDbContext> options) : base(options) { }
        
        public DbSet<Room> Rooms { get; set; } = null!;
        public DbSet<Message> Messages { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Room>().HasKey(r => r.RoomId);

            modelBuilder.Entity<Message>().HasKey(m => new { m.RoomId, m.Id, m.Time }); // 복합 PK

            modelBuilder.Entity<Message>()
                .HasOne<Room>()
                .WithMany()
                .HasForeignKey(m => m.RoomId)
                .OnDelete(DeleteBehavior.Cascade); // 방 삭제시 메시지 자동 삭제
        }
    }


    [Table("roomTBL")]
    public class Room
    {
        [Key]
        [Column("roomid")]
        [MaxLength(8)]
        public string RoomId { get; set; }

        [Column("modified_date")]
        public DateTime ModifiedDate { get; set; }
    }

    [Table("messageTBL")]
    public class Message
    {
        [Column("roomid")]
        [MaxLength(8)]
        public string RoomId { get; set; }

        [Column("id")]
        [MaxLength(10)]
        public string Id { get; set; } // 유저 ID

        [Column("time")]
        public DateTime Time { get; set; }

        [Column("content")]
        public string Content { get; set; }
    }
}