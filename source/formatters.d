module formatters;

import std.stdio;
import std.conv;
import std.functional;
import std.string;
import std.algorithm;
import std.datetime;
import types;

interface ILogFormatter
{
    string formatLine(in LogEntry* entry);
}

alias formatterFunc = string delegate(in LogEntry *entry);

string fmtTimestamp(in LogEntry *entry)
{
    return Clock.currTime().toUnixTime().to!string;
}

string fmtGetSeverity(in LogEntry *entry)
{
    return entry.severity.to!string;
}

string fmtGetMessage(in LogEntry *entry)
{
    return entry.message;
}

class StandardFormatter : ILogFormatter
{
    protected string formatMask = "[{severity}][{timestamp}] {message}";
    protected formatterFunc[string] fmtMap;

    this()
    {
        addHandler("timestamp", (&fmtTimestamp).toDelegate());
        addHandler("severity", (&fmtGetSeverity).toDelegate());
        addHandler("message", (&fmtGetMessage).toDelegate());
    }

    void setFormat(string fmt)
    {
        format = fmt;
    }

    void addHandler(string marker, formatterFunc func)
    {
        fmtMap[marker] = func;
    }

    string formatLine(in LogEntry* entry)
    {
        auto line = formatMask.dup;

        foreach (pair; fmtMap.byKeyValue())
        {
            line = line.replace("{" ~ pair.key ~ "}", pair.value()(entry));
        }
        return line.to!string;
    }
}
