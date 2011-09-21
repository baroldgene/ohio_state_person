require "OhioStatePerson/version"

module OhioStatePerson

	def self.included(base)
		base.instance_eval do
			validates_uniqueness_of :name_n
			validates_format_of :name_n, :with => /\A[a-z]([a-z-]*[a-z])?\.[1-9]\d*\z/, :message => 'must be in format: name.#'

			validates_uniqueness_of :emplid
			validates_format_of :emplid, :with => /\A\d{8,9}\z/, :message => 'must be 8 or 9 digits'

			before_validation :set_id, :on => :create
			validate :id_is_emplid


			def self.search(q)
				q.strip! if q
				case q
				when /\A\d+\z/
					where(:emplid => q)
				when /\A\D+\.\d+\z/
					where(:name_n => q)
				when /(\S+),\s*(\S+)/
					where('last_name LIKE ? AND first_name LIKE ?', $1, "#{$2}%")
				when /(\S+)\s+(\S+)/
					where('first_name LIKE ? AND last_name LIKE ?', $1, "#{$2}%")
				when /\S/
					where('last_name LIKE ?', "#{q}%")
				else
					where('1=2')
				end
			end

		end
	end

	def email
		name_n.present? ? "#{name_n}@osu.edu" : ''
	end

	protected

	def set_id
		self.id = self.emplid.to_i
	end

	def id_is_emplid
		unless self.id == self.emplid.to_i
			errors.add(:id, 'must be the same as the emplid')
		end
	end

end
