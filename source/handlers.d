module handlers;

import std.stdio;
import std.file;
import std.exception;

import types;
import formatters;

interface ILogHandler
{
    void handle(in LogEntry* message);
}

abstract class BaseHandler
{
    protected ILogFormatter formatter;

    this()
    {
        formatter = new StandardFormatter();
    }

    this(ILogFormatter fmt)
    {
        setFormatter(fmt);
    }

    ILogFormatter getFormatter()
    {
        return formatter;
    }

    void setFormatter(ILogFormatter fmt)
    {
        formatter = fmt;
    }
}

class StdoutHandler : BaseHandler, ILogHandler
{
    this()
    {
        super();
    }

    this(ILogFormatter formatter)
    {
        super(formatter);
    }

    void handle(in LogEntry* entry)
    {
        if(entry.severity == Severity.ERROR || entry.severity ==  Severity.FATAL || entry.severity ==  Severity.WARNING){
            stderr.writeln(formatter.formatLine(entry));
            return;
        }
        writeln(formatter.formatLine(entry));
    }

}

class TextFileHandler : BaseHandler, ILogHandler
{
    File fh;

    this(string fileName)
    {
        prepareLogFile(fileName);
        super();
    }

    this(string fileName, ILogFormatter formatter)
    {
        prepareLogFile(fileName);
        super(formatter);
    }

    protected void prepareLogFile(string fileName)
    {
        try
        {
            fh = File(fileName, "a");
        }
        catch (ErrnoException e)
        {
            writefln("Cannot open file for writing: %s", fileName);
        }
    }

    void handle(in LogEntry* entry)
    {
        if (fh.isOpen())
        {
            fh.writeln(formatter.formatLine(entry));
        }
    }

    ~this()
    {
        if (fh.isOpen())
        {
            fh.close();
        }
    }
}
