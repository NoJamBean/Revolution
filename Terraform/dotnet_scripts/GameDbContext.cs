using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyApi.Data
{
    public class GameDbContext : DbContext
    {
        public GameDbContext(DbContextOptions<GameDbContext> options) : base(options) { }

        public DbSet<GameInfo> GameInfos { get; set; } = null!;
        public DbSet<GameResult> GameResults { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<GameInfo>()
                .HasKey(g => new { g.Id, g.GameDate });

            modelBuilder.Entity<GameResult>()
                .HasKey(g => new { g.Id, g.GameDate });

            modelBuilder.Entity<GameResult>()
                .HasOne(gr => gr.GameInfo)
                .WithMany()
                .HasForeignKey(gr => new { gr.Id, gr.GameDate })
                .OnDelete(DeleteBehavior.Cascade);
        }
    }

    [Table("gameinfoTBL")]
    public class GameInfo
    {
        [Key]
        [Column("id")]
        [MaxLength(10)]
        public string? Id { get; set; }

        [Required]
        [Column("type")]
        public string? Type { get; set; }

        [Required]
        [Column("gameDate")]
        public DateTime GameDate { get; set; }

        [Required]
        [Column("home")]
        [MaxLength(20)]
        public string? Home { get; set; }

        [Required]
        [Column("away")]
        [MaxLength(20)]
        public string? Away { get; set; }

        [Required]
        [Column("wdl")]
        public string? Wdl { get; set; }  // 'win', 'draw', 'lose'

        [Required]
        [Column("odds", TypeName = "decimal(5,2)")]
        public decimal Odds { get; set; }

        [Column("price", TypeName = "bigint")]
        public long Price { get; set; } = 0;

        [Column("status")]
        public bool Status { get; set; } = true;

        public GameInfo() {}
    }

    [Table("gameresultTBL")]
    public class GameResult
    {
        [Key]
        [Column("id")]
        [MaxLength(10)]
        public string? Id { get; set; }

        [Required]
        [Column("type")]
        public string? Type { get; set; }

        [Required]
        [Column("gameDate")]
        public DateTime GameDate { get; set; }

        [Required]
        [Column("home")]
        [MaxLength(20)]
        public string? Home { get; set; }

        [Required]
        [Column("away")]
        [MaxLength(20)]
        public string? Away { get; set; }

        [Required]
        [Column("odds", TypeName = "decimal(5,2)")]
        public decimal Odds { get; set; }
        
        [Column("price", TypeName = "bigint")]
        public long Price { get; set; } = 0;
        
        [Column("result")]
        [Required]
        public string? Result { get; set; }  // 'win', 'lose'

        [Column("resultPrice", TypeName = "bigint")]
        public long ResultPrice { get; set; } = 0;

        // 외래 키 관계 설정
        [ForeignKey("Id, GameDate")]
        public virtual GameInfo GameInfo { get; set; }

        public GameResult() {}
    }
}
