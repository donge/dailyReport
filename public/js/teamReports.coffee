treeList = new TreeList2("#userTree")

userData = []
ReportModel.getSubordinateUser((response)->
  return if response.state == 0
  userData = response.data
  console.log userData
  setTeam(userData)
  treeList.renderTree("#userTree", userData))

#设置用户编辑界面状态
$("#userTree").on("review", (event)->
  userId = event["itemId"]
  initPageState()
  reportvm.userId(userId)
  getSummary())