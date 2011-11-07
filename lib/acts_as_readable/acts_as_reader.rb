module ActsAsReader #:nodoc:
  module ActMethod
    def acts_as_reader
      has_many :readings, :dependent => :destroy
    end
  end
end