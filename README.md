# slog

Slog is a structured logging library, modeled after Golang's equally named `slog`.

## Usage

Basic usage is just a simple string as a message:

```janet
(slog/info "my message")
#=> stdout: time="2023-07-07T18:50:54Z" level="info" msg="my message"
```

More context can be added by just sending more parameters:

```janet
(slog/debug "failed login" :user_id 1)
#=> stdout: time="2023-07-07T18:50:54Z" level="debug" msg="failed login" user_id="1"
```

The number of parameters after the message have to be even. This won't work:

```janet
(slog/error "this won't work" :a 1 :b)
#=> error: slog: arguments have odd number of elements.
```

### Customizing

The default logger prints out to `stdout` with a text formatter. That behaviour
can be changed by creating your own logger, with `slog/new`, which takes a
file or buffer as its first argument. This returns a function which takes an
even number of arguments and prints them out to the given buffer.

```janet
(def mylogger (slog/new (file/open "foo.log" :a)))
(mylogger :level :debug :msg "custom")
(mylogger :level :info :msg "custom")
#=> $ cat foo.log
# time="2023-07-07T19:00:42Z" level="debug" msg="custom"
# time="2023-07-07T19:00:42Z" level="info" msg="custom"
```

You can make this the default logger:

```janet
(slog/set-default mylogger)
(slog/debug "another one")
#=> $ cat foo.log
# time="2023-07-07T19:00:42Z" level="debug" msg="custom"
# time="2023-07-07T19:00:42Z" level="info" msg="custom"
# time="2023-07-07T19:02:13Z" level="debug" msg="another one"
```

Output can be changed to JSON by passing a formatter, which is a function which
takes an even-numbered tuple and returns a string:

```janet
(defn format-json [tuple] (json/encode (struct ;tuple)))
(def mylogger (slog/new stdout :formatter format-json))
(mylogger :level :debug)
#=> stdout: {"time":"2023-07-07T19:02:13Z","level":"debug"}
```

By default time is time in UTC formatted in ISO 8601. That can also be changed,
by passing a function which takes no arguments and returns a string:

```janet
(defn mytimer [] "always now")
(def mylogger (slog/new stdout :timer mytimer))
(mylogger :level :debug :msg "another one")
#=> stdout: time="always now" level="debug" msg="another one"
```

### Log level

You can define the minimal log level, so only messages at or above that level
get printed:

```janet
(slog/set-level :error)
(slog/debug "won't print")
(slog/info "won't print")
(slog/error "will print")
(slog/fatal "will print")
(slog/unknown "will print")
```
