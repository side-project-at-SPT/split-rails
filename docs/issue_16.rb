# 3.3.4 :001 > Visitor.pluck(:role).tally
#   Visitor Pluck (49.4ms)  SELECT "visitors"."role" FROM "visitors"
#  => {"guest"=>161, "user"=>8, "ai"=>1}
# 3.3.4 :002 > _.values.sum
#  => 170
# 3.3.4 :003 > Visitor.last
#   Visitor Load (46.3ms)  SELECT "visitors".* FROM "visitors" ORDER BY "visitors"."id" DESC LIMIT $1  [["LIMIT", 1]]
#  =>
# #<Visitor:0x00000001238d2088
#  id: 170,
#  name: "guest_20241001_6outiu7yXS",
#  password_digest: "[FILTERED]",
#  created_at: Wed, 02 Oct 2024 00:33:03.856654000 CST +08:00,
#  updated_at: Wed, 02 Oct 2024 00:33:03.879645000 CST +08:00,
#  preferences: {"nickname"=>"guest"},
#  role: "guest">
