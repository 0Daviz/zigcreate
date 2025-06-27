const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const templates = @import("templates.zig");

//shit
//we build build file
pub fn run(allocator: std.mem.Allocator, project_name: []const u8) !void {
    if (project_name.len == 0) {
        std.debug.print("Error: Project name cannot be empty\n", .{});
        return error.InvalidProjectName;
    }

    var dir = fs.cwd().openDir(project_name, .{}) catch |err| {
        switch (err) {
            error.FileNotFound => {},
            else => return err,
        }
        //dir exists? yes no maybe?
        try fs.cwd().makeDir(project_name);
        std.debug.print("Created project '{s}'\n", .{project_name});

        try createBuildFile(allocator, project_name);
        try createMainFile(allocator, project_name);
        try createReadme(allocator, project_name);

        std.debug.print("Success! Project initialized in '{s}'\n", .{project_name});
        return;
    };
    defer dir.close();
    std.debug.print("Error: Directory '{s}' already exists\n", .{project_name});
    return error.DirectoryExists;
}

fn createBuildFile(allocator: std.mem.Allocator, project_name: []const u8) !void {
    const build_file = try fs.cwd().createFile(try mem.concat(allocator, u8, &[_][]const u8{ project_name, "/build.zig" }), .{});
    defer build_file.close();

    const content = try templates.getBuildContent(allocator, project_name);
    defer allocator.free(content);
    try build_file.writeAll(content);
}

fn createMainFile(allocator: std.mem.Allocator, project_name: []const u8) !void {
    try fs.cwd().makeDir(try mem.concat(allocator, u8, &[_][]const u8{ project_name, "/src" }));

    const main_file = try fs.cwd().createFile(try mem.concat(allocator, u8, &[_][]const u8{ project_name, "/src/main.zig" }), .{});
    defer main_file.close();
    try main_file.writeAll(templates.MAIN_FILE_CONTENT);
}

fn createReadme(allocator: std.mem.Allocator, project_name: []const u8) !void {
    try fs.cwd().makeDir(try mem.concat(allocator, u8, &[_][]const u8{ project_name, "/tests" }));
    const readme = try fs.cwd().createFile(try mem.concat(allocator, u8, &[_][]const u8{ project_name, "/README.md" }), .{});
    defer readme.close();

    const content = try templates.getReadmeContent(allocator, project_name);
    defer allocator.free(content);
    try readme.writeAll(content);
}

pub fn addLibrary(allocator: std.mem.Allocator, lib_name: []const u8) !void {
    if (lib_name.len == 0) {
        std.debug.print("Error: Library name cannot be empty\n", .{});
        return error.InvalidLibraryName;
    }
    const lib_path = try fs.path.join(allocator, &[_][]const u8{ "lib", lib_name });
    defer allocator.free(lib_path);

    const src_path = try fs.path.join(allocator, &[_][]const u8{ lib_path, "src" });
    defer allocator.free(src_path);

    try fs.cwd().makePath(src_path);
    const build_path = try fs.path.join(allocator, &[_][]const u8{ lib_path, "build.zig" });
    defer allocator.free(build_path);

    const build_file = try fs.cwd().createFile(build_path, .{});
    defer build_file.close();

    const build_content = try std.fmt.allocPrint(allocator,
        \\const std = @import("std");
        \\
        \\pub fn build(b: *std.Build) void {{
        \\    const target = b.standardTargetOptions(.{{}});
        \\    const optimize = b.standardOptimizeOption(.{{}});
        \\
        \\    const lib = b.addStaticLibrary(.{{
        \\        .name = "{s}",
        \\        .root_source_file = .{{ .path = "src/main.zig" }},
        \\        .target = target,
        \\        .optimize = optimize,
        \\    }});
        \\    b.installArtifact(lib);
        \\}}
    , .{lib_name});
    defer allocator.free(build_content);
    try build_file.writeAll(build_content);
    const main_path = try fs.path.join(allocator, &[_][]const u8{ src_path, "main.zig" });
    defer allocator.free(main_path);

    const main_file = try fs.cwd().createFile(main_path, .{});
    defer main_file.close();

    const main_content = try std.fmt.allocPrint(allocator,
        \\const std = @import("std");
        \\
        \\pub fn init() void {{
        \\    std.debug.print("Hello from {s} library!\n", .{{}});
        \\}}
        \\
        \\test "basic test" {{
        \\    try std.testing.expect(1 + 1 == 2);
        \\}}
    , .{lib_name});
    defer allocator.free(main_content);
    try main_file.writeAll(main_content);
    try updateRootBuild(allocator, lib_name);

    std.debug.print("Added library '{s}'\n", .{lib_name});
}
fn updateRootBuild(allocator: std.mem.Allocator, lib_name: []const u8) !void {
    const build_path = "build.zig";
    var build_file = try std.fs.cwd().openFile(build_path, .{ .mode = .read_write });
    defer build_file.close();

    const content = try build_file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);
    const dep_pattern = try std.fmt.allocPrint(allocator, ".addModule(\"{s}\"", .{lib_name});
    defer allocator.free(dep_pattern);
    if (std.mem.indexOf(u8, content, dep_pattern) != null) {
        std.debug.print("Library '{s}' is already linked\n", .{lib_name});
        return;
    }

    const exe_pos = std.mem.indexOf(u8, content, "const exe = b.addExecutable");
    const lib_pos = std.mem.indexOf(u8, content, "const lib = b.addStaticLibrary");

    const decl_pos = exe_pos orelse lib_pos orelse {
        std.debug.print(
            \\Error: Invalid project structure.
            \\Your build.zig must contain either:
            \\1. const exe = b.addExecutable(...); OR
            \\2. const lib = b.addStaticLibrary(...);
            \\
            \\Please create a valid project first using:
            \\zigcreate myproject
            \\
        , .{});
        return error.InvalidBuildFile;
    };

    const var_start = decl_pos + "const ".len;
    const var_end = std.mem.indexOfPos(u8, content, var_start, " ") orelse {
        std.debug.print("Error: Malformed build declaration\n", .{});
        return error.InvalidBuildFile;
    };

    if (var_end <= var_start) {
        std.debug.print("Error: Couldn't parse build declaration\n", .{});
        return error.InvalidBuildFile;
    }

    const var_name = content[var_start..var_end];
    const insert_pos = std.mem.indexOfPos(u8, content, decl_pos, ";\n") orelse content.len;

    const new_content = try std.fmt.allocPrint(allocator, "{s}\n\n    // Added by zigcreate\n    const {s}_dep = b.dependency(\"{s}\", .{{ .target = target, .optimize = optimize }});\n    {s}.addModule(\"{s}\", {s}_dep.module(\"{s}\"));\n{s}", .{
        content[0..insert_pos],
        lib_name,
        lib_name,
        var_name,
        lib_name,
        lib_name,
        lib_name,
        content[insert_pos..],
    });
    defer allocator.free(new_content);

    try build_file.seekTo(0);
    try build_file.writeAll(new_content);
    try build_file.setEndPos(new_content.len);
}

//gitignore added
fn createGitignore(allocator: std.mem.Allocator, project_name: []const u8) !void {
    const gitignore_path = try fs.path.join(allocator, &[_][]const u8{ project_name, ".gitignore" });
    defer allocator.free(gitignore_path);

    const file = try fs.cwd().createFile(gitignore_path, .{});
    defer file.close();
    try file.writeAll(templates.GITIGNORE_CONTENT);
}
