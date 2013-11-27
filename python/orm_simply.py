class Model(object):
	"""docstring for Model"""
	def __init__(self):
		super(Model, self).__init__()
		self.__class__.tablename = str(self.__class__.__name__).lower()

	def create(self):
		sql = "INSERT INTO " + self.__class__.tablename + " ("
		fields = []
		intos = []
		values = []
		for attr in self.__dict__:
			key = attr.lower()
			value = getattr(self, attr)
			fields.append(key)
			if isinstance(value, datetime):
				intos.append("UTC_TIMESTAMP()")
			else:
				intos.append("%s")
				values.append(value)
		sql = sql + ','.join(fields) +") VALUES("+','.join(intos)+')'
		insertArgs = tuple(values)
		self.id = db.execute(sql, *insertArgs)

	def update(self):
		set_fields = []
		values = []
		for attr in self.__dict__:
			key = attr.lower()
			value = getattr(self, attr)
			if attr != "id":
				set_fields.append('='.join([key, "%s"]))
				values.append(value)
		sql ="UPDATE "+ self.__class__.tablename+" SET " + ','.join(set_fields)+" WHERE id=%s"
		print sql
		print values
		values.append(self.id)
		updateArgs = tuple(values)
		db.execute(sql, *updateArgs)

	@classmethod
	def get(self, **kargv):
		where_field = []
		values = []
		for attr, value in kargv:
			where_field.append('='.join([attr, '%s']))
			values.append(value);

		sql = "SELECT * FROM "+ self.__class__.tablename+" WHERE "+' and '.join(where_field)
		selectArg = tuple(values)
		result = db.query(sql, *selectArg)
		print result;
