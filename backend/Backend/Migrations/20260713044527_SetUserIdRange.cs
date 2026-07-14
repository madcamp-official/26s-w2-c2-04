using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Backend.Migrations
{
    /// <inheritdoc />
    public partial class SetUserIdRange : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // NOT VALID: 이미 10001 미만 ID로 존재하는 로우는 검사하지 않고, 이후 INSERT/UPDATE부터만 강제한다.
            migrationBuilder.Sql(
                "ALTER TABLE \"Users\" ADD CONSTRAINT \"CK_Users_Id_Range\" " +
                "CHECK (\"Id\" >= 10001 AND \"Id\" <= 99999) NOT VALID;");

            migrationBuilder.Sql("ALTER SEQUENCE \"Users_Id_seq\" RESTART WITH 10001;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("ALTER SEQUENCE \"Users_Id_seq\" RESTART WITH 1;");

            migrationBuilder.DropCheckConstraint(
                name: "CK_Users_Id_Range",
                table: "Users");
        }
    }
}
