const std = @import("std");
const create = @import("create.zig");

pub fn main() !void {
    //allocator (frees memory)
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    //gets command line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        printHelp();
        std.process.exit(1);
    }

    if (std.mem.eql(u8, args[1], "-h") or std.mem.eql(u8, args[1], "--help")) {
        printHelp();
        return;
    }

    if (std.mem.eql(u8, args[1], "library")) {
        if (args.len < 3) {
            std.debug.print("Error: Library name required\n\n", .{});
            printHelp();
            std.process.exit(1);
        }
        try create.addLibrary(allocator, args[2]);
        return;
    }

    const project_name = args[1];
    try create.run(allocator, project_name);
}

fn printHelp() void {
    std.debug.print(
        \\zigcreate - Create Zig project templates
        \\
        \\Usage:
        \\  zigcreate <project_name>    Create new project
        \\  zigcreate library <name>    Add library to existing project
        \\  zigcreate -h | --help      Show this help
        \\
        \\Examples:
        \\  zigcreate my_awesome_project
        \\  zigcreate library mylib
        \\
    , .{});
}
