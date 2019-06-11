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

/**
Main logger class. Use it to write logs in your app
*/
class Logger
{
    IDispatcher dispatcher;
    Verbosity verbosity;

    protected LogBuffer buffer;

    /**
    Default constructor. Default SyncDispatcher will be user as log dispatcher
    */
    this()
    {
        dispatcher = new SyncDispatcher(this);
    }

    /**
    Overloaded construtor. You may specify custom dispatcher using this method
    */
    this(IDispatcher dispatcher)
    {
        this.dispatcher = dispatcher;
    }

    /**
    Overloaded constructor. You may specify custom log dispatcher and log buffer.
    In this case all logging operations will be buffered
    */
    this(IDispatcher dispatcher, LogBuffer buffer)
    {
        this.dispatcher = dispatcher;
        this.buffer = buffer;
    }

    /**
    Add log handler. 
    */
    void addHandler(ILogHandler newHandler)
    {
        dispatcher.addHandler(newHandler);
    }

    /**
    TODO
    Set logger verbosity level
    */
    void setVerbosity(Verbosity verbosity)
    {
        // dispatcher.verbosity = verbosity;
    }

    /**
    Write log message. Severity.INFO will be used as default
    */
    void log(string message)
    {
        insertMessage(new LogEntry(Severity.INFO, message));
    }

    /**
    Write log message with params specified
    */
    void log(string message, string[string] params)
    {
        insertMessage(new LogEntry(Severity.INFO, message, params));
    }

    /**
    Write log message with severity specified
    */
    void log(string message, Severity severity)
    {
        insertMessage(new LogEntry(severity, message));
    }

    /**
    Write log message with severity and params specified
    */
    void log(string message, Severity severity, string[string] params)
    {
        insertMessage(new LogEntry(severity, message, params));
    }

    /**
    Process log entry. This method will add log entry to buffer if exists, or
        performs direct dispatch if no log buffer specified
    */
    protected void insertMessage(LogEntry* entry)
    {
        if (buffer !is null)
        {
            buffer.add(entry);
            return;
        }
        dispatcher.dispatch(entry);
    }

    /**
    Setter for log buffer
    */
    void setBuffer(LogBuffer buffer)
    {
        this.buffer = buffer;
    }

    /**
    Getter for log buffer
    */
    LogBuffer getBuffer()
    {
        return buffer;
    }
}

/**
Buffer container for log messages
*/
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

    ~this()
    {
        flush();
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
            if (item.key < current)
            {
                logger.dispatcher.dispatch(item.value);
            }
        }
        current = 0;
    }
}

/**
Standard synchronous log dispatcher
*/
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

unittest
{
    auto logger = new Logger();
    assert(cast(SyncDispatcher) logger.dispatcher);
    assert(logger.getBuffer() is null);

    logger.setBuffer(new LogBuffer(logger));
    assert(logger.buffer.bufferSize == 10);
    assert(logger.buffer.buffer.length == 0);

    for (int i = 0; i < 15; i++)
    {
        logger.log(i.to!string);
    }
    assert(logger.buffer.buffer.length == 10);
    assert(logger.buffer.current == 5);
}
