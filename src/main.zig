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
        return;
    }

    if (std.mem.eql(u8, args[1], "-h") or std.mem.eql(u8, args[1], "--help")) {
        printHelp();
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
        \\  zigcreate -h | --help      Show this help
        \\
        \\Example:
        \\  zigcreate my_awesome_project
        \\
    , .{});
}
