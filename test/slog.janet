(import ../slog)
(use tester)

(defsuite "slog"
  (test "format-text keeps order of attributes"
        (is (= `time="1" level="info" msg="test" a="1" b="2"`
               (slog/format-text [:time 1 :level :info :msg "test" :a 1 :b 2]))))

  (test "escapes quotes inside strings"
        (is (= `time="1" level="info" msg="with \"quotes\""`
               (slog/format-text [:time 1 :level :info :msg `with "quotes"`]))))

  (def fake-timer (fn [] "now"))

  (test "uses the given timer function"
        (let [buf @""
              logger (slog/new buf :timer fake-timer)]
          (logger :level :warn :msg "something" :a 1)
          (is (= "time=\"now\" level=\"warn\" msg=\"something\" a=\"1\"\n" (string buf)))))

  (test "uses the given formatter function"
        (let [buf @""
              fn (fn [tup] (string/format "%q" (struct ;tup))) # formats as janet would
              logger (slog/new buf :formatter fn :timer fake-timer)]
          (logger :msg "something")
          (is (= "{:msg \"something\" :time \"now\"}\n" (string buf))))))
