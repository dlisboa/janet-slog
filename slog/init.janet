(import json)

(defn- now []
  "Current UTC time in iso8601"
  (let [date (os/date)
        M (inc (date :month))
        D (inc (date :month-day))
        Y (date :year)
        HH (date :hours)
        MM (date :minutes)
        SS (date :seconds)]
    (string/format "%d-%.2d-%.2dT%.2d:%.2d:%.2dZ" Y M D HH MM SS)))

(defn format-text [tuple]
  (as-> tuple tup
        (partition 2 tup)
        (map (fn [[k v]] (string/format `%s=%v` (string k) (string v))) tup)
        (string/join tup " ")))

(var- *level* 0)
(def- levels {:debug 0 :info 1 :warn 2 :error 3 :fatal 4 :unknown 5})
(defn set-level
  ``Sets the minimal log level. Messages with level at or above this get printed.

  Example:
      (slog/set-level :info)

  The levels and their indexes are:
      {:debug 0 :info 1 :warn 2 :error 3 :fatal 4 :unknown 5}
  ``
  [key]
  (set *level* (levels key)))

(defn new
  ``Given a stream, which can be a buffer or a file, returns a new logger function.

  Named arguments are two functions:
      formatter: (fn [tuple] string) -> takes a tuple and returns a string
      timer: (fn [] string) -> takes nothing and returns a string

  Example:
      (slog/new stdout) # this is the default logger
  ``
  [stream &named formatter timer]
  (default formatter format-text)
  (default timer now)
  (def write-fn (if (buffer? stream) buffer/push file/write))

  (fn [& args]
    (when (odd? (length args))
      (error "slog: arguments have odd number of elements."))
    (def lvl (levels ((struct ;args) :level)))
    (if (>= lvl *level*)
      (write-fn stream
                (string (formatter [:time (timer) ;args]) "\n")))))

(var- *logger* (new stdout))
(defn set-default
  "Sets the default logger to `l`."
  [l]
  (set *logger* l))

(defn debug   [msg & rest] (*logger* :level :debug :msg msg ;rest))
(defn info    [msg & rest] (*logger* :level :info :msg msg ;rest))
(defn warn    [msg & rest] (*logger* :level :warn :msg msg ;rest))
(defn error   [msg & rest] (*logger* :level :error :msg msg ;rest))
(defn fatal   [msg & rest] (*logger* :level :fatal :msg msg ;rest))
(defn unknown [msg & rest] (*logger* :level :unknown :msg msg ;rest))
