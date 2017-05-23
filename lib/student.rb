require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end

  def save
    create_sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    if self.id
      self.update
    else
      DB[:conn].execute(create_sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end

  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?;
    SQL

    DB[:conn].execute(sql, [self.name, self.grade, self.id])
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?;
    SQL

    row = DB[:conn].execute(sql, name)[0]
    Student.new_from_db(row)
  end
end
