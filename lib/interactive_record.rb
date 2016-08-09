require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'


class InteractiveRecord

	def self.table_name
    	self.to_s.downcase.pluralize
	end

	def self.column_names
		# binding.pry
    	DB[:conn].results_as_hash = true

    	sql = "pragma table_info('#{table_name}')"

    	table_info = DB[:conn].execute(sql)
   		column_names = []
    	table_info.each do |row|
	      	column_names << row["name"]
	    end
    # binding.pry
    	column_names.compact
	end

	def initialize(options={})
    	options.each do |property, value|
    		self.send("#{property}=", value)
    	end
  	end

  	def table_name_for_insert
    	self.class.table_name
	end

	def col_names_for_insert
		# binding.pry
	   	self.class.column_names.delete_if {|col| col == "id"}.join(", ")
	end

  	def values_for_insert
    	values = []
    	self.class.column_names.each do |col_name|
    		values << "'#{send(col_name)}'" unless send(col_name).nil?
    	end
    	values.join(", ")
	end

  	def save
	    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
	   
	    DB[:conn].execute(sql)
	    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
	end

	def self.find_by_name(name)
    	sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    
    	DB[:conn].execute(sql)
	end

	def self.find_by(options = {})
		# binding.pry
		# sql = "SELECT * FROM #{self.table_name} WHERE '#{arg.keys.join}' = '#{arg.values}'"
		
		# DB[:conn].execute(sql)

		sql = "SELECT * FROM '#{self.table_name}' WHERE name = ? OR grade = ?"

		DB[:conn].execute(sql, options[:name], options[:grade])
	end



		# DB[:conn].execute(sql,
		# "#{self.column_names_for_insert}"

# binding.pry
		# somecolumn = {}
		# column_names_for_insert.each do |column|
		# 		if column == hash
		# 			somecolumn = column
		# 		end
		# 	end

		# DB[:conn].execute(sql, somecolumn, hash)


			# somecolumn.each do |column|
			# 	if column == hash
			# 		hash
			# 		DB[:conn].execute(sql, hash)
			# 	end
			# end
			# # )
	# end

end