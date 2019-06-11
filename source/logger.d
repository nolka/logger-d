module logger;

import std.stdio;
import std.conv;
import std.concurrency;

import types;
import handlers;

interface IDispatcher
{
    void addHandler(ILogHandler newHandler);
    void dispatch(in LogEntry* entry);
}

class Logger
{
    IDispatcher dispatcher;
    Verbosity verbosity;
    protected LogBuffer buffer;

    this()
    {
        dispatcher = new SyncDispatcher(this);
        buffer = new LogBuffer(this);
    }

    this(IDispatcher disp)
    {
        dispatcher = disp;
        buffer = new LogBuffer(this);
    }

    void addHandler(ILogHandler newHandler)
    {
        dispatcher.addHandler(newHandler);
    }

    void setVerbosity(Verbosity verbosity)
    {
        // dispatcher.verbosity = verbosity;
    }

    void log(string message)
    {
        insertMessage(new LogEntry(Severity.INFO, message));
    }

    void log(string message, string[string] params)
    {
        insertMessage(new LogEntry(Severity.INFO, message, params));
    }

    void log(string message, Severity severity)
    {
        insertMessage(new LogEntry(severity, message));
    }

    void log(string message, Severity severity, string[string] params)
    {
        auto entry = new LogEntry(severity, message, params);
        insertMessage(entry);
    }

    protected void insertMessage(LogEntry* entry)
    {
        buffer.add(entry);
    }

    void flush()
    {
        buffer.flush();
    }

    ~this()
    {
        buffer.flush();
    }
}

class LogBuffer
{
    int bufferSize = 10;
    LogEntry*[int] buffer;
    Logger logger;

    protected int current = 0;

    this(Logger log, int bufferSize = 10)
    {
        logger = log;
        this.bufferSize = bufferSize;
    }

    void add(LogEntry* entry)
    {
        buffer[current++] = entry;
        if (current >= bufferSize)
        {
            flush();
        }
    }

    void flush()
    {
        foreach (item; buffer.byKeyValue())
        {
            if(item.key < current){
                logger.dispatcher.dispatch(item.value);
            }
        }
        current = 0;
    }
}

class SyncDispatcher : IDispatcher
{
    Verbosity verbosity;

    private ILogHandler[] handlers;
    private Logger logger;

    this(Logger logger)
    {
        logger = logger;
    }

    void addHandler(ILogHandler newHandler)
    {
        handlers ~= newHandler;
    }

    void dispatch(in LogEntry* entry)
    {
        foreach (handler; handlers)
        {
            handler.handle(entry);
        }
    }
}
