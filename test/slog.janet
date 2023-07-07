(import ../slog)

# format-text keeps order of attributes
(assert (= `time="1" level="info" msg="test" a="1" b="2"`
           (slog/format-text [:time 1 :level :info :msg "test" :a 1 :b 2])))
# escapes quotes inside strings
(assert (= `time="1" level="info" msg="with \"quotes\""`
           (slog/format-text [:time 1 :level :info :msg `with "quotes"`])))

(def fake-timer (fn [] "now"))

# prints into the buffer
(var buf @"")
(var logger (slog/new buf :timer fake-timer))
(logger :level :warn :msg "something" :a 1)
(assert (compare= "time=\"now\" level=\"warn\" msg=\"something\" a=\"1\"\n"
                  (string buf)))

# accepts a different formatter
(var buf @"")
(defn- janet-fmt [tuple] (string/format "%q" (struct ;tuple))) # formats as janet would
(var logger (slog/new buf :formatter janet-fmt :timer fake-timer))
(logger :msg "something")
(assert (compare= "{:msg \"something\" :time \"now\"}\n" (string buf)))
