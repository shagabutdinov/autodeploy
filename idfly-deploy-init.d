#!/usr/bin/env ruby

COMMAND = './idfly-deploy'
ARGS = []

PID_PATH = "/var/run/#{COMMAND}.pid"
OUT_LOG_PATH = "/var/log/#{COMMAND}.out"
ERR_LOG_PATH = "/var/log/#{COMMAND}.err"

require 'shellwords'

def start()
  command = Shellwords.join([COMMAND, *ARGS])
  STDOUT.write("Executing: #{command}... ")

  pid = Process.spawn(
    command, in: '/dev/null',
    out: OUT_LOG_PATH,
    err: ERR_LOG_PATH
  )

  File.write(PID_PATH, pid)
  Process.detach(pid)
  sleep(0.1)
  status = Shellwords.join(['ps', '-h', File.read(PID_PATH)])
  if `#{status}`.empty?()
    puts('Failed')
  else
    puts('Ok')
  end
end

def stop()
  pid = File.read(PID_PATH) rescue nil
  if pid == nil || pid.empty?()
    puts "#{COMMAND} is not running"
    return
  end

  Process.kill(:INT, pid)
  File.delete(PID_PATH)
end

def restart()
  stop()
  start()
end

def status()
  if !File.exist?(PID_PATH)
    puts("#{COMMAND} stopped")
    return
  end

  status = system(Shellwords.join(['ps', '-h', File.read(PID_PATH)]))
  puts(`#{status}`)
end

commands = ['start', 'stop', 'restart', 'status']
if !commands.include?(ARGV[0])
  raise Error.new("Wrong command \"#{ARGV[0]}\"; allowed commands: #{commands}")
end

Object.method(ARGV[0]).call()