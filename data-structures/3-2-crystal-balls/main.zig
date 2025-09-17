const std = @import("std");
const expect = std.testing.expect;
const testing = std.testing;
const math = std.math;

fn twoCrystalBallsSearch(floors: []const bool) usize {
    if (floors.len == 0) return 0;

    const jumpSize: usize = math.sqrt(floors.len);
    var i: usize = jumpSize;

    while (i < floors.len) {
        if (floors[i]) break;
        i += jumpSize;
    }

    // Go back to last known good point
    i -= jumpSize;
    var j: usize = 0;

    while (i + j < floors.len) {
        if (floors[i + j]) {
            return i + j;
        }
        j += 1;
    }

    return 0;
}

// LLM written tests
// Helper to create a floors slice of length `len` where floors[i] == (i >= break_idx).
// That is, the first `break_idx` entries are false, then all remaining are true.
fn buildFloors(allocator: std.mem.Allocator, len: usize, break_idx: usize) ![]bool {
    var arr = try allocator.alloc(bool, len);
    var i: usize = 0;
    while (i < len) : (i += 1) {
        arr[i] = i >= break_idx;
    }
    return arr;
}

// If the function is in another file, import it; otherwise, the tests assume it is in this file:
// const twoCrystalBallsSearch = @import("path/to/file.zig").twoCrystalBallsSearch;

// Basic correctness: break at index 0
test "twoCrystalBallsSearch: break at start (index 0)" {
    const floors = try buildFloors(testing.allocator, 16, 0);
    defer testing.allocator.free(floors);

    try testing.expectEqual(@as(usize, 0), twoCrystalBallsSearch(floors));
}

// Break in the middle
test "twoCrystalBallsSearch: break near middle" {
    const floors = try buildFloors(testing.allocator, 101, 57);
    defer testing.allocator.free(floors);

    try testing.expectEqual(@as(usize, 57), twoCrystalBallsSearch(floors));
}

// Break at the very end (last index true only)
test "twoCrystalBallsSearch: break at end (last index)" {
    const len: usize = 97;
    const floors = try buildFloors(testing.allocator, len, len - 1);
    defer testing.allocator.free(floors);

    try testing.expectEqual(len - 1, twoCrystalBallsSearch(floors));
}

// Perfect square length to stress sqrt-jump boundaries
test "twoCrystalBallsSearch: perfect square length" {
    const len: usize = 36;
    const floors = try buildFloors(testing.allocator, len, 30);
    defer testing.allocator.free(floors);

    try testing.expectEqual(@as(usize, 30), twoCrystalBallsSearch(floors));
}

// Very small arrays
test "twoCrystalBallsSearch: small arrays" {
    // len = 1, break at 0
    {
        const floors = try buildFloors(testing.allocator, 1, 0);
        defer testing.allocator.free(floors);
        try testing.expectEqual(@as(usize, 0), twoCrystalBallsSearch(floors));
    }

    // len = 2, break at 1
    {
        const floors = try buildFloors(testing.allocator, 2, 1);
        defer testing.allocator.free(floors);
        try testing.expectEqual(@as(usize, 1), twoCrystalBallsSearch(floors));
    }

    // len = 3, break at 2
    {
        const floors = try buildFloors(testing.allocator, 3, 2);
        defer testing.allocator.free(floors);
        try testing.expectEqual(@as(usize, 2), twoCrystalBallsSearch(floors));
    }
}

// Randomized fuzz: multiple lengths and break positions
test "twoCrystalBallsSearch: randomized fuzz" {
    var prng = std.Random.DefaultPrng.init(0xdead_beef);
    const rand = prng.random();

    var case_idx: usize = 0;
    while (case_idx < 25) : (case_idx += 1) {
        // length in [1, 500]
        const len = @max(@as(usize, 1), rand.intRangeAtMost(usize, 1, 500));
        // break_idx in [0, len-1]
        const break_idx = rand.intRangeAtMost(usize, 0, len - 1);

        const floors = try buildFloors(testing.allocator, len, break_idx);
        defer testing.allocator.free(floors);

        const got = twoCrystalBallsSearch(floors);
        try testing.expectEqual(break_idx, got);
    }
}
