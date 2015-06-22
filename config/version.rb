module OpenCourts
  module VERSION
    MAJOR = 1
    MINOR = 3
    PATCH = 8

    PRE = 'beta'

    STRING = [MAJOR, MINOR, PATCH, PRE].compact.join '.'
  end
end
