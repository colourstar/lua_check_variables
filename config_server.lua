------------------------- 目录设置 --------------------
-- 游戏目录
config_file_path = '../../logic/clientlogic/'
-- 生成文件存放目录
save_data_path = 'ldb'
-- estrdream存放目录
config_estrdream_path = "type/estrdream"
-- enumdream存放目录
config_enumdream_path = "type/enumdream"
-- 代码目录
config_o = "data"
config_p = "program"

package.path = package.path .. ';../../skynet/luaclib/?.so;'
------------------------- 功能设置 --------------------

-- 开启升级更新功能
NEED_UPDATE = false

-- 处理无效的占位数据
PROCESS_INVAILD_DATA = true

-- 输出数据表中所有的farg
OUTPUT_DATA_FARG = false

-- 输出数据表class属性中的farg
OUTPUT_CLASS_FARG = false