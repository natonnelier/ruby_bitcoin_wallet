require 'openssl'

module ::OpenSSL
  class BN
    def self.from_hex(hex); new(hex, 16); end
    def to_hex; to_i.to_s(16); end
    def to_mpi; to_s(0).unpack("C*"); end
  end
  class PKey::EC
    def private_key_hex; private_key.to_hex.rjust(64, '0'); end
    def public_key_hex;  public_key.to_hex.rjust(130, '0'); end
    def pubkey_compressed?; public_key.group.point_conversion_form == :compressed; end
  end
  class PKey::EC::Point
    def self.from_hex(group, hex)
      new(group, BN.from_hex(hex))
    end
    def to_hex; to_bn.to_hex; end
    def self.bn2mpi(hex) BN.from_hex(hex).to_mpi; end
    def ec_add(point); self.class.new(group, OpenSSL::BN.from_hex(OpenSSL_EC.ec_add(self, point))); end
  end
end
