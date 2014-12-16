require 'csv'
require 'fileutils'
require 'trollop'
require 'uuidtools'


# CLI Interface
opts = Trollop::options do
  opt :source, "path/to/csv/file", type: :string, default:  "../corporate-gray-moaa-6-20141211-204645.csv"
  opt :destination, "path/to/csv/destination/folder", type: :string, default: "./"
end


# Object to store all of the information for each applicant
class Applicant

  @@count = 0

  attr_reader :first_name, :last_name, :email, :street_address, :city, :state_province, :zipcode, :mil_branch, :mil_rank, :relocate, :date_available, :education_level, :clearance, :resume

  def initialize(first_name, last_name, email, street_address, city, state_province, zipcode, mil_branch, mil_rank, relocate, date_available, education_level, clearance, resume)
    @first_name = first_name
    @last_name = last_name
    @email = email
    @street_address = street_address
    @city = city
    @state_province = state_province
    @zipcode = zipcode
    @mil_branch = mil_branch
    @mil_rank = mil_rank
    @relocate = relocate
    @date_available = date_available
    @education_level = education_level
    @clearance = clearance
    @resume = resume
    @@count += 1
  end

  # Access the count for file naming
  def self.count
    @@count
  end

  # How many zero's does the filename need
  def write_zeros
    total_digits = 8
    zeros = total_digits - (@@count.to_s.length)
  end
  
  # Method for file naming
  def file_name
    file_name = "h"
    write_zeros.times { file_name += "0" }
    file_name += @@count.to_s + ".txt"
  end

  # Make sure values are in quotes and nil values are empty strings
  def create_value(val)
    val ? "\"#{val}\"" : ""
  end

  # Create the new csv format in the proper order
  def create_file_string
    "#{create_value(@first_name)}, #{create_value(@last_name)}, #{create_value(@street_address)}, #{create_value(@city)}, #{create_value(@state_province)}, \"US\", #{create_value(@zipcode)}, \"\", #{create_value(@email)}, \"\", \"\", \"\", \"\", \"\", #{create_value(@mil_rank)}, #{create_value(@mil_branch)}, #{create_value(@clearance)}, #{create_value(@education_level)}, #{create_value(@relocate)}, #{create_value(@date_available)}"
  end

end

class Resume

  @@count = 0

  attr_reader :id, :url

    def initialize(id, url)
      @id = id
      @url = url
    end

    def self.count
      @@count
    end

    def file_ending
      @url.split(".")[-1]
    end

    def write_zeros
      zeros = 8 - (@id.to_s.length)
    end

    def file_name
      if @url
        file_name = "r"
        write_zeros.times { file_name += "0" }
        file_name += "#{@id.to_s}.#{file_ending}"
      else
        false
      end
    end

    def write_file(resume_destination)
      file = file_name
      if file
        system("curl -sS -o #{resume_destination}/#{file} #{@url}")
        @@count += 1
      end
    end
end

def write_files(source, header_destination, resume_destination)
  
  # Hash to convert from string representation to integer representation for rank from the csv file
  rank_values = {
    "E1" => 3,
    "E2" => 22,
    "E3" => 23,
    "E4" => 24,
    "E5" => 25,
    "E6" => 26,
    "E7" => 27,
    "E8" => 28,
    "E9" => 29,
    "W1" => 16,
    "W2" => 31,
    "W3" => 32,
    "W4" => 33,
    "W5" => 34,
    "O1" => 13,
    "O2" => 5,
    "O3" => 6,
    "O4" => 7,
    "O5" => 8,
    "O6" => 9,
    "O7" => 10,
    "O8" => 12,
    "O9" => 11,
    "010" => 35,
    "Civilian" => 37
  }

  # Hash to convert branch strings to branch integers
  branch_values = {
    nil => 0,
    "Unspecified" => 0,
    "Army" => 1,
    "Navy" => 2,
    "Air Force" => 3,
    "Marine Corps" => 4,
    "Coast Guard" => 5,
    "Army Reserve" => 6,
    "Navy Reserve" => 7,
    "Air Force Reserve" => 8,
    "Marine Corps Reserve" => 9,
    "Army National Guard" => 10,
    "Coast Guard Reserve" => 12,
    "Air National Guard" => 13,
    "Other" => 14
  }

  # Hash to convert clearance strings to integers
  clearance_values = {
    nil => 0,
    "Unspecified" => 0,
    "Secret" => 1,
    "Top Secret" => 2,
    "None" => 3
  }

  # Hash to convert education strings to integers
  education_values = {
    nil => 0,
    "Unspecified" => 0,
    "High School or GED" => 1,
    "Associates Degree" => 3,
    "Bachelors Degree" => 4,
    "Masters Degree" => 4,
    "PhD" => 4
  }
  # Go throught every row of the csv file
  puts "Fetching resumes and csv data..."
  begin
    # Try to read the source file
    CSV.foreach(source) do |row|

      # Store every column value of a row in an Application instance
      app = Applicant.new(
        row[0], # First name
        row[1], # Last name
        row[2], # Email
        row[11], # Street Address
        row[12], # City
        row[13], # State Province
        row[14], # Zipcode
        branch_values[row[17]], # Military Branch
        rank_values[row[18]], # Military Rank
        row[21] ? row[21].downcase : "", # Willing to Relocate, downcased
        row[22], # Date Available
        education_values[row[23]], # Education Level
        clearance_values[row[25]], # Clearance
        row[27], # Resume
      )

      resume = Resume.new(
        Applicant.count,
        row[27]
      )

      # Write a new file and pass the csv contents to it
      new_file = File.open("#{header_destination}/#{app.file_name}", "w")
      new_file.write app.create_file_string
      new_file.close

      # Write a new file for the resume
      resume.write_file(resume_destination)

      # Show progress to user
      print "."
    end
      puts "\n#{Applicant.count} csv files and #{Resume.count} resume files successfully created"
    return true

  rescue Errno::ENOENT
    return false 
  end
end

def prompt(source, destination)

  # Make sure the destination folder exists
  unless system("ls #{destination} >&/dev/null")

    # If the destination doesn't exist, ask the user to create it
    puts "Folder #{destination} does not exist, create #{destination}? (y/n)"
    continue = gets.chomp
    case continue
    when "y"
      # Create the destination folder if the user wants to
      FileUtils.mkdir destination
    when "n"
      # Terminate the program if users decides not to create destination
      return "Folder not created. No files written. Exiting..."
    else
      # If user enters invalid choice, don't guess. Just terminat the program
      return "Invalid selection. No files written. Exiting..."
    end
  end

  # Date default file endings
  date_string = "#{Time.now}"[0..9]

  # Staging area in tmp directory
  staging_area = "#{ENV['TMPDIR']}csv-reader/#{UUIDTools::UUID.timestamp_create}"
  pwd = Dir.pwd

  # Create folders in staging areas to be zipped
  resumes_folder = "#{staging_area}/resumes-#{date_string}"
  headers_folder = "#{staging_area}/headers-#{date_string}"
  resumes_string = "resumes-#{date_string}"
  headers_string = "headers-#{date_string}"
  FileUtils.mkdir_p resumes_folder
  FileUtils.mkdir_p headers_folder
  
  begin
    # Call write files method
    worked = write_files(source, headers_folder, resumes_folder)

    # If source file is not found, report to user
    unless worked
      FileUtils.remove_dir headers_folder
      FileUtils.remove_dir resumes_folder
      return "#{source} not found. Ending program."
    end

  rescue
    # End program and delete progress if something goes wrong
    FileUtils.remove_dir headers_folder
    FileUtils.remove_dir resumes_folder
    return "Something went wrong writing files, deleting progress..."
  end

  begin
    # Zip up the headers folder
    puts "Zipping up #{headers_folder}..."
    system("cd #{staging_area}; zip -qr #{headers_string}.zip #{headers_string}")
  rescue
    # Leave folder for user to zip up later, move to next folder
    puts "Unable to zip #{headers_folder}. Folder intact, manual zipping required."
  end

  begin
    # Attempt to zip up resumes folder
    puts "Zipping up #{resumes_folder}..."
    system("cd #{staging_area}; zip -qr #{resumes_string}.zip #{resumes_string}")
  rescue
    # Leave original folder intact for user to manually zip later
    puts "Unable to zip #{resumes_folder}. Folder intact, manual zipping required"
  end
  
  begin
    # Copy zip files from stagin area to destination
    puts "Bringing zip files from #{staging_area} to #{destination}"
    system("cd #{pwd}")
    system("cp #{resumes_folder}.zip #{destination}")
    system("cp #{headers_folder}.zip #{destination}")
  rescue
    return "Unable to copy zipped filed to #{destination}. They are located here: #{staging_area}"
  end

  # Tell user the program finished
  return "Done"

end

# Call prompt method to start program
puts prompt(opts[:source], opts[:destination])

