set :output, nil
every 1.minute do 
  rake 'push:process_queue'
end
