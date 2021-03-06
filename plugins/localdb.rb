#!/usr/bin/env ruby
#
# Plugin localdb
# Author L
#
# 查询本地data/db/*.bin的数据库文件(收集了53W的收费hash)

plugin 'localdb' do 
  supported_algorithm :md5, :md5_16, :sha1, :mysql, :ntlm, :lm

  crack {
    enum_algorithm do |algorithm|
      names = [algorithm]
      case algorithm
      when :lm
        key = passwd[8,16].hex2int
        names = ['lm']
      when :ntlm
        key = passwd[8,16].hex2int
        names = ['ntlm']
      when :md5
        key = passwd[8,16].hex2int
        names = %w( md5 md5x2 md5x3 )
      when :serv_u
        key = passwd[8,16].hex2int
        names = ['md5']
      when :md5_16
        key = passwd.hex2int
        names = %w( md5 md5x2 md5x3 )
      when :dedecms
        key = passwd.hex2int
        names = ['md5']
      when :sha1
        key = passwd[10,16].hex2int
      when :mysql
        key = passwd[10,16].hex2int
      end

      load_obj = ->(file) { MessagePack.unpack(File.binread(file)) }

      names.find do |name|
        file = "#{ROOT}/data/db/#{name}.bin"
        if File.exist? file
          hash = load_obj.call(file)
          index = hash[key]
          if index
            words = load_obj.call("#{ROOT}/data/db/words.bin")
            break words[index]
          end
        end
      end
    end
  }
end

