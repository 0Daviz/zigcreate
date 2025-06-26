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
    // here we make main file similiar process
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
