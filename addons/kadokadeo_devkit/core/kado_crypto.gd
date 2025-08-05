extends Node
class_name KadoCrypto

var aes = AESContext.new()
var crypto = Crypto.new()
var server_public_key: CryptoKey

func set_server_public_key(key: String) -> void:
	server_public_key = CryptoKey.new()
	server_public_key.load_from_string(key, true)

func apply_pkcs7_padding(data: PackedByteArray, block_size: int) -> PackedByteArray:
	var padding_length = block_size - (data.size() % block_size)
	var padding = PackedByteArray()
	for i in range(padding_length):
		padding.append(padding_length)
	return data + padding

func prepare_payload(payload: String) -> SecurePayload:
	var key = crypto.generate_random_bytes(16)
	var key_signed = crypto.encrypt(server_public_key, key)
	var iv = crypto.generate_random_bytes(16)

	var payload_bytes = payload.to_utf8_buffer()
	var padded_payload = apply_pkcs7_padding(payload_bytes, 16)

	# Encrypt CBC
	aes.start(AESContext.MODE_CBC_ENCRYPT, key, iv)
	var encrypted = aes.update(padded_payload)
	aes.finish()

	var payload_data = iv + encrypted

	return SecurePayload.new(
		Marshalls.raw_to_base64(payload_data),
		Marshalls.raw_to_base64(key_signed),
		Marshalls.raw_to_base64(crypto.hmac_digest(HashingContext.HASH_SHA256, key, payload.to_utf8_buffer()))
	)
