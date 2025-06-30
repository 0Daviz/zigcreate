const std = @import("std");

pub const MAIN_FILE_CONTENT =
    \\const std = @import("std");
    \\
    \\pub fn main() void {
    \\    std.debug.print("Hello, world!\n", .{});
    \\}
;

pub fn getBuildContent(allocator: std.mem.Allocator, project_name: []const u8) ![]const u8 {
    const header =
        \\const std = @import("std");
        \\
        \\pub fn build(b: *std.Build) void {
        \\    const target = b.standardTargetOptions(.{});
        \\    const optimize = b.standardOptimizeOption(.{});
        \\
        \\    const lib = b.addStaticLibrary(.{
        \\        .name = "
    ;

    const footer =
        \\",
        \\        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        \\        .target = target,
        \\        .optimize = optimize,
        \\    });
        \\    b.installArtifact(lib);
        \\}
    ;

    return try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ header, project_name, footer });
}

pub fn getReadmeContent(allocator: std.mem.Allocator, project_name: []const u8) ![]const u8 {
    const header = "\\# ";
    const body =
        \\\nA Zig project generated with [zigcreate](https://github.com/0Daviz/zigcreate).
        \\
        \\## Build
        \\```sh
        \\zig build
        \\```
    ;

    return try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ header, project_name, body });
}

pub const BUILD_FILE_CONTENT =
    \\const std = @import("std");
    \\
    \\pub fn build(b: *std.Build) void {
    \\    const target = b.standardTargetOptions(.{});
    \\    const optimize = b.standardOptimizeOption(.{});
    \\
    \\    const exe = b.addExecutable(.{
    \\        .name = "myproject",
    \\        .root_source_file = .{ .cwd_relative = "src/main.zig" },
    \\        .target = target,
    \\        .optimize = optimize,
    \\    });
    \\
    \\    b.installArtifact(exe);
    \\}
;

pub const GITIGNORE_CONTENT =
    \\# Zig build artifacts
    \\zig-cache/
    \\zig-out/
    \\
    \\# Binaries/objects
    \\*.o
    \\*.obj
    \\*.exe
    \\
    \\# Editors/IDEs
    \\.vscode/
    \\.idea/
    \\
    \\# System files
    \\.DS_Store
;
