module logger;

import std.stdio;
import std.concurrency;

import types;
import handlers;

interface IDispatcher
{
    void addHandler(ILogHandler newHandler);
    void dispatch(in LogEntry entry);
}

class Logger
{
    protected IDispatcher dispatcher;

    this()
    {
        dispatcher = new SyncDispatcher(this);
    }

    this(IDispatcher disp)
    {
        dispatcher = disp;
    }

    void addHandler(ILogHandler newHandler)
    {
        dispatcher.addHandler(newHandler);
    }

    void log(string message)
    {
        dispatcher.dispatch(LogEntry(Severity.INFO, message));
    }

    void log(string message, string[string] params)
    {
        dispatcher.dispatch(LogEntry(Severity.INFO, message, params));
    }

    void log(string message, Severity severity)
    {
        dispatcher.dispatch(LogEntry(severity, message));
    }

    void log(string message, Severity severity, string[string] params)
    {
        dispatcher.dispatch(LogEntry(severity, message, params));
    }
}

class SyncDispatcher : IDispatcher
{
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

    void dispatch(in LogEntry entry)
    {
        foreach (handler; handlers)
        {
            handler.handle(entry);
        }
    }
}
