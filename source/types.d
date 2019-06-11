module types;

import std.stdio;

enum Severity
{
    INFO,
    DEBUG,
    WARNING,
    ERROR,
    FATAL,
};

enum Verbosity
{
    VERBOSE = 1,
    DEBUG = 2,
}

struct LogEntry
{
    string message;
    Severity severity;
    string[string] params;

    public this(Severity sevetiry, string message)
    {
        this.message = message;
        this.severity = severity;
    }

    public this(Severity sevetiry, string message, string[string] params)
    {
        this.message = message;
        this.severity = severity;
        this.params = params;
    }
}
