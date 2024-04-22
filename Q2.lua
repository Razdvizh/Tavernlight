function printSmallGuildNames(memberCount)
  -- this method is supposed to print names of all guilds that have less than memberCount max members
  local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
  local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))
  if not resultId then
	return
  end
  -- Discovered that `result` is an iterator. Iterate the query result and print guild names.
  repeat
	local guildName = result.getString(resultId, "name")
	print(guildName)
  until not result.next(resultId)
  result.free(resultId) -- release query.
end
