namespace :ristretto do
  desc "Set up a fresh cloned git repo for operation"
  task :setup do
    ['database','settings', 'sunspot'].each do |file|
      if ! File.exists?(Rails.root.join('config',"#{file}.yml"))
        sh "cp #{Rails.root.join('config',"#{file}.example.yml")} #{Rails.root.join('config',"#{file}.yml")}"
      end
    end
  end
end
