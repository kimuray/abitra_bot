# 出力先のログファイルの指定
require File.expand_path(File.dirname(__FILE__) + "/environment")
set :output, 'log/crontab.log'
# ジョブの実行環境の指定
set :environment, :production
# # 1分毎に回す
