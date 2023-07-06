(import date)

(var *level* 1)
(def- levels [:debug :info :warn :error :fatal :unknown])

(defn text-handler [dict]
  (string/join (seq [[k v] :pairs dict] (string k "=" v))
               " "))

(defn- new-record [keys time-fn]
  (def tab @{ :time (time-fn) })
  (merge-into tab keys))

(defn new [buf &opt encode-fn time-fn]
  (default encode-fn text-handler)
  (default time-fn |(:strftime (:gmtime (date/time)) :iso8601))

  (fn [&keys keys]
    (def write-fn (if (buffer? buf) buffer/push file/write))
    (def lvl (index-of (keys :level) levels))
    (if (>= lvl *level*)
      (write-fn buf (string (encode-fn (new-record keys time-fn))
                            "\n")))))

(var *default* (new stdout))

(defn debug [msg &keys keys]
  (*default* :level :debug :msg msg ;(kvs keys)))
(defn info [msg &keys keys]
  (*default* :level :info :msg msg ;(kvs keys)))
(defn warn [msg &keys keys]
  (*default* :level :warn :msg msg ;(kvs keys)))
(defn error [msg &keys keys]
  (*default* :level :error :msg msg ;(kvs keys)))
(defn fatal [msg &keys keys]
  (*default* :level :fatal :msg msg ;(kvs keys)))
(defn unknown [msg &keys keys]
  (*default* :level :unknown :msg msg ;(kvs keys)))

