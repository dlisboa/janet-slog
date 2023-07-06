(declare-project
  :name "slog"
  :description ```slog is a structured logging library. ```
  :dependencies ["https://github.com/cosmictoast/janet-date"]
  :version "0.0.0")

(declare-source
  :prefix "slog"
  :source ["slog/init.janet"])
