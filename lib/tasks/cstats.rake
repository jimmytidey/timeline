desc "Cucumber Statistics"

task :cstats do
  sum = 0
  features_folder = File.join(Rails.root.to_s, 'features')
  steps_folder = File.join(Rails.root.to_s, 'features', 'step_definitions')

  Dir.open(features_folder).each do |f|
    File.open(File.join(features_folder, f), "r") do |file|
      next if File.directory?(file)
      sum += file.readlines.length
    end
  end

  Dir.open(steps_folder).each do |f|
    file_name = File.join(steps_folder, f)
    File.open(file_name, "r") do |file|
      next if File.directory?(file)
      next if File.basename(file_name) == "webrat_steps.rb"
      sum += file.readlines.length
    end
  end
  
  stats       = `cd #{File.join(Rails.root.to_s)} && rake stats`
  code_lines  = stats.match(/Code LOC:(?:\s+)(\d+)/)[1].to_i
  ratio       = sum.to_f/code_lines.to_f
  puts "Code Lines: #{code_lines}"
  puts "Test Lines: #{sum}"
  puts "Code to Test Ration: #{sprintf("%.1f",ratio)}"
end
