pub const Error = error{
    InvalidArgs,
    InvalidProjectName,
    InvalidLibraryName,
    DirectoryExists,
    CreateDirFailed,
    CreateFileFailed,
    WriteFailed,
    InvalidBuildFile,
};
