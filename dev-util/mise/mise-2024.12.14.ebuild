# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Autogenerated by pycargoebuild 0.13.2

EAPI=8

CRATES="
	addr2line@0.21.0
	adler2@2.0.0
	adler@1.0.2
	aead@0.5.2
	aes-gcm@0.10.3
	aes@0.8.4
	age-core@0.10.0
	age@0.10.1
	ahash@0.8.11
	aho-corasick@1.1.3
	android-tzdata@0.1.1
	android_system_properties@0.1.5
	ansi-str@0.8.0
	ansitok@0.2.0
	anstream@0.6.18
	anstyle-parse@0.2.6
	anstyle-query@1.1.2
	anstyle-wincon@3.0.6
	anstyle@1.0.10
	anyhow@1.0.94
	arbitrary@1.4.1
	arc-swap@1.7.1
	arrayvec@0.5.2
	async-compression@0.4.18
	atomic-waker@1.1.2
	autocfg@1.4.0
	backtrace@0.3.71
	base64@0.21.7
	base64@0.22.1
	base64ct@1.6.0
	basic-toml@0.1.9
	bech32@0.9.1
	beef@0.5.2
	binstall-tar@0.4.42
	bit-set@0.6.0
	bit-vec@0.7.0
	bitflags@2.6.0
	block-buffer@0.10.4
	bstr@1.11.1
	built@0.7.5
	bumpalo@3.16.0
	bytecount@0.6.8
	byteorder@1.5.0
	bytes@1.9.0
	bzip2-sys@0.1.11+1.0.8
	bzip2@0.4.4
	bzip2@0.5.0
	calm_io@0.1.1
	calmio_filters@0.1.0
	cc@1.2.4
	cfg-if@1.0.0
	cfg_aliases@0.2.1
	chacha20@0.9.1
	chacha20poly1305@0.10.1
	chrono-tz-build@0.3.0
	chrono-tz@0.9.0
	chrono@0.4.39
	ci_info@0.14.14
	cipher@0.4.4
	clap@4.5.23
	clap_builder@4.5.23
	clap_derive@4.5.18
	clap_lex@0.7.4
	clap_mangen@0.2.24
	color-eyre@0.6.3
	color-print-proc-macro@0.3.7
	color-print@0.3.7
	color-spantrace@0.2.1
	colorchoice@1.0.3
	comfy-table@7.1.3
	confique-macro@0.0.11
	confique@0.3.0
	console@0.15.10
	const-oid@0.9.6
	constant_time_eq@0.3.1
	contracts@0.6.3
	convert_case@0.4.0
	cookie-factory@0.3.3
	core-foundation-sys@0.8.7
	core-foundation@0.10.0
	core-foundation@0.9.4
	countme@3.0.1
	cpufeatures@0.2.16
	crc-catalog@2.4.0
	crc32fast@1.4.2
	crc@3.2.1
	crossbeam-channel@0.5.14
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.21
	crossterm@0.28.1
	crossterm_winapi@0.9.1
	crypto-common@0.1.6
	ctor@0.2.9
	ctr@0.9.2
	curve25519-dalek-derive@0.1.1
	curve25519-dalek@4.1.3
	darling@0.20.10
	darling_core@0.20.10
	darling_macro@0.20.10
	dashmap@5.5.3
	deflate64@0.1.9
	demand@1.5.0
	der@0.7.9
	deranged@0.3.11
	derive_arbitrary@1.4.1
	derive_more@0.99.18
	deunicode@1.6.0
	diff@0.1.13
	digest@0.10.7
	directories@5.0.1
	dirs-sys@0.4.1
	displaydoc@0.2.5
	document-features@0.2.10
	dotenvy@0.15.7
	duct@0.13.7
	dunce@1.0.5
	ed25519-dalek@2.1.1
	ed25519@2.2.3
	either@1.13.0
	encode_unicode@1.0.0
	encoding_rs@0.8.35
	env_filter@0.1.2
	env_logger@0.11.5
	envmnt@0.10.4
	equivalent@1.0.1
	erased-serde@0.4.5
	errno-dragonfly@0.1.2
	errno@0.2.8
	errno@0.3.10
	exec@0.3.1
	expr-lang@0.2.1
	eyre@0.6.12
	fastrand@2.3.0
	fiat-crypto@0.2.9
	filetime@0.2.25
	filetime_creation@0.2.0
	find-crate@0.6.3
	fixedbitset@0.4.2
	flate2@1.0.35
	fluent-bundle@0.15.3
	fluent-langneg@0.13.0
	fluent-syntax@0.11.1
	fluent@0.16.1
	fnv@1.0.7
	foreign-types-shared@0.1.1
	foreign-types@0.3.2
	form_urlencoded@1.2.1
	fsio@0.4.0
	fslock@0.2.1
	futures-channel@0.3.31
	futures-core@0.3.31
	futures-executor@0.3.31
	futures-io@0.3.31
	futures-macro@0.3.31
	futures-sink@0.3.31
	futures-task@0.3.31
	futures-util@0.3.31
	futures@0.3.31
	fuzzy-matcher@0.3.7
	generic-array@0.14.7
	getrandom@0.2.15
	ghash@0.5.1
	gimli@0.28.1
	git2@0.19.0
	glob@0.3.1
	globset@0.4.15
	globwalk@0.9.1
	h2@0.4.7
	hashbrown@0.12.3
	hashbrown@0.14.5
	hashbrown@0.15.2
	heck@0.4.1
	heck@0.5.0
	hermit-abi@0.3.9
	hex@0.4.3
	hkdf@0.12.4
	hmac@0.12.1
	home@0.5.9
	homedir@0.3.4
	http-body-util@0.1.2
	http-body@1.0.1
	http@1.2.0
	httparse@1.9.5
	humansize@2.1.3
	humantime@2.1.0
	hyper-rustls@0.27.4
	hyper-tls@0.6.0
	hyper-util@0.1.10
	hyper@1.5.2
	i18n-config@0.4.7
	i18n-embed-fl@0.7.0
	i18n-embed-impl@0.8.4
	i18n-embed@0.14.1
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.61
	icu_collections@1.5.0
	icu_locid@1.5.0
	icu_locid_transform@1.5.0
	icu_locid_transform_data@1.5.0
	icu_normalizer@1.5.0
	icu_normalizer_data@1.5.0
	icu_properties@1.5.1
	icu_properties_data@1.5.0
	icu_provider@1.5.0
	icu_provider_macros@1.5.0
	ident_case@1.0.1
	idna@1.0.3
	idna_adapter@1.2.0
	ignore@0.4.23
	impl-tools-lib@0.11.0
	impl-tools@0.10.2
	indenter@0.3.3
	indexmap@1.9.3
	indexmap@2.7.0
	indicatif@0.17.9
	indoc@2.0.5
	inout@0.1.3
	insta@1.41.1
	intl-memoizer@0.5.2
	intl_pluralrules@7.0.2
	io_tee@0.1.1
	ipnet@2.10.1
	is_terminal_polyfill@1.70.1
	itertools@0.10.5
	itertools@0.13.0
	itoa@1.0.14
	jobserver@0.1.32
	js-sys@0.3.76
	junction@1.2.0
	kdl@4.7.0
	lazy-regex-proc_macros@3.3.0
	lazy-regex@3.3.0
	lazy_static@1.5.0
	libc@0.2.168
	libgit2-sys@0.17.0+1.8.1
	libm@0.2.11
	libredox@0.1.3
	libssh2-sys@0.3.0
	libz-sys@1.1.20
	linked-hash-map@0.5.6
	linux-raw-sys@0.4.14
	litemap@0.7.4
	litrs@0.4.1
	lock_api@0.4.12
	lockfree-object-pool@0.1.6
	log@0.4.22
	logos-derive@0.12.1
	logos@0.12.1
	lua-src@547.0.0
	luajit-src@210.5.11+97813fb
	lzma-rs@0.3.0
	lzma-rust@0.1.7
	lzma-sys@0.1.20
	matchers@0.1.0
	md-5@0.10.6
	memchr@2.7.4
	miette-derive@7.4.0
	miette@7.4.0
	mime@0.3.17
	minimal-lexical@0.2.1
	miniz_oxide@0.7.4
	miniz_oxide@0.8.2
	mio@1.0.3
	mlua-sys@0.6.6
	mlua@0.10.2
	mlua_derive@0.10.1
	native-tls@0.2.12
	nix@0.29.0
	nom@7.1.3
	nt-time@0.8.1
	nu-ansi-term@0.46.0
	num-conv@0.1.0
	num-traits@0.2.19
	num_cpus@1.16.0
	number_prefix@0.4.0
	object@0.32.2
	once_cell@1.20.2
	opaque-debug@0.3.1
	openssl-macros@0.1.1
	openssl-probe@0.1.5
	openssl-sys@0.9.104
	openssl@0.10.68
	option-ext@0.2.0
	ordered-float@2.10.1
	os-release@0.1.0
	os_pipe@1.2.1
	overload@0.1.1
	owo-colors@3.5.0
	papergrid@0.13.0
	parking_lot@0.12.3
	parking_lot_core@0.9.10
	parse-zoneinfo@0.3.1
	paste@1.0.15
	path-absolutize@3.1.1
	path-dedot@3.1.1
	pbkdf2@0.12.2
	percent-encoding@2.3.1
	pest@2.7.15
	pest_derive@2.7.15
	pest_generator@2.7.15
	pest_meta@2.7.15
	petgraph@0.6.5
	phf@0.11.2
	phf_codegen@0.11.2
	phf_generator@0.11.2
	phf_shared@0.11.2
	pin-project-internal@1.1.7
	pin-project-lite@0.2.15
	pin-project@1.1.7
	pin-utils@0.1.0
	pkcs8@0.10.2
	pkg-config@0.3.31
	platforms@3.5.0
	poly1305@0.8.0
	polyval@0.6.2
	portable-atomic@1.10.0
	powerfmt@0.2.0
	ppv-lite86@0.2.20
	pretty_assertions@1.4.1
	proc-macro-error-attr2@2.0.0
	proc-macro-error-attr@1.0.4
	proc-macro-error2@2.0.1
	proc-macro-error@1.0.4
	proc-macro2@1.0.92
	quick-xml@0.23.1
	quinn-proto@0.11.9
	quinn-udp@0.5.9
	quinn@0.11.6
	quote@1.0.37
	rand@0.8.5
	rand_chacha@0.3.1
	rand_core@0.6.4
	rayon-core@1.12.1
	rayon@1.10.0
	redox_syscall@0.5.8
	redox_users@0.4.6
	regex-automata@0.1.10
	regex-automata@0.4.9
	regex-syntax@0.6.29
	regex-syntax@0.8.5
	regex@1.11.1
	reqwest@0.12.9
	ring@0.17.8
	rmp-serde@1.3.0
	rmp@0.8.14
	roff@0.2.2
	rops@0.1.4
	rowan@0.15.16
	rust-embed-impl@8.5.0
	rust-embed-utils@8.5.0
	rust-embed@8.5.0
	rustc-demangle@0.1.24
	rustc-hash@1.1.0
	rustc-hash@2.1.0
	rustc_version@0.4.1
	rustix@0.38.42
	rustls-native-certs@0.8.1
	rustls-pemfile@2.2.0
	rustls-pki-types@1.10.1
	rustls-webpki@0.102.8
	rustls@0.23.20
	rustversion@1.0.18
	ryu@1.0.18
	salsa20@0.10.2
	same-file@1.0.6
	schannel@0.1.27
	scopeguard@1.2.0
	scrypt@0.11.0
	secrecy@0.8.0
	security-framework-sys@2.13.0
	security-framework@2.11.1
	security-framework@3.1.0
	self-replace@1.5.0
	self_cell@0.10.3
	self_cell@1.1.0
	self_update@0.41.0
	semver@1.0.24
	serde-value@0.7.0
	serde@1.0.216
	serde_derive@1.0.216
	serde_ignored@0.1.10
	serde_json@1.0.133
	serde_regex@1.1.0
	serde_spanned@0.6.8
	serde_urlencoded@0.7.1
	serde_with@3.11.0
	serde_with_macros@3.11.0
	serde_yaml@0.9.34+deprecated
	sevenz-rust@0.6.1
	sha1@0.10.6
	sha2@0.10.8
	sharded-slab@0.1.7
	shared_child@1.0.1
	shell-escape@0.1.5
	shell-words@1.1.0
	shlex@1.3.0
	signal-hook-registry@1.4.2
	signal-hook@0.3.17
	signature@2.2.0
	simd-adler32@0.3.7
	similar@2.6.0
	siphasher@0.3.11
	siphasher@1.0.1
	slab@0.4.9
	slug@0.1.6
	smallvec@1.13.2
	socket2@0.5.8
	spin@0.9.8
	spki@0.7.3
	stable_deref_trait@1.2.0
	strsim@0.10.0
	strsim@0.11.1
	strum@0.26.3
	strum_macros@0.26.4
	subtle@2.6.1
	syn@1.0.109
	syn@2.0.90
	sync_wrapper@1.0.2
	synstructure@0.13.1
	sys-info@0.9.1
	system-configuration-sys@0.6.0
	system-configuration@0.6.1
	tabled@0.17.0
	tabled_derive@0.9.0
	taplo@0.13.2
	tar@0.4.43
	tempfile@3.14.0
	tera@1.20.0
	termcolor@1.4.1
	terminal_size@0.4.1
	test-log-macros@0.2.16
	test-log@0.2.16
	text-size@1.1.1
	thiserror-impl@1.0.69
	thiserror-impl@2.0.8
	thiserror@1.0.69
	thiserror@2.0.8
	thread_local@1.1.8
	time-core@0.1.2
	time-macros@0.2.19
	time@0.3.37
	tinystr@0.7.6
	tinyvec@1.8.0
	tinyvec_macros@0.1.1
	tokio-macros@2.4.0
	tokio-native-tls@0.3.1
	tokio-rustls@0.26.1
	tokio-util@0.7.13
	tokio@1.42.0
	toml@0.5.11
	toml@0.8.19
	toml_datetime@0.6.8
	toml_edit@0.22.22
	tower-service@0.3.3
	tracing-attributes@0.1.28
	tracing-core@0.1.33
	tracing-error@0.2.1
	tracing-log@0.2.0
	tracing-subscriber@0.3.19
	tracing@0.1.41
	try-lock@0.2.5
	type-map@0.5.0
	typeid@1.0.2
	typenum@1.17.0
	ubi@0.2.4
	ucd-trie@0.1.7
	unic-char-property@0.9.0
	unic-char-range@0.9.0
	unic-common@0.9.0
	unic-langid-impl@0.9.5
	unic-langid@0.9.5
	unic-segment@0.9.0
	unic-ucd-segment@0.9.0
	unic-ucd-version@0.9.0
	unicode-ident@1.0.14
	unicode-segmentation@1.12.0
	unicode-width@0.1.14
	unicode-width@0.2.0
	universal-hash@0.5.1
	unsafe-libyaml@0.2.11
	untrusted@0.9.0
	url@2.5.4
	urlencoding@2.1.3
	usage-lib@1.7.2
	utf16_iter@1.0.5
	utf8_iter@1.0.4
	utf8parse@0.2.2
	valuable@0.1.0
	vcpkg@0.2.15
	version_check@0.9.5
	versions@6.3.2
	vfox@0.3.4
	vte@0.10.1
	vte_generate_state_changes@0.1.2
	walkdir@2.5.0
	want@0.3.1
	wasi@0.11.0+wasi-snapshot-preview1
	wasm-bindgen-backend@0.2.99
	wasm-bindgen-futures@0.4.49
	wasm-bindgen-macro-support@0.2.99
	wasm-bindgen-macro@0.2.99
	wasm-bindgen-shared@0.2.99
	wasm-bindgen@0.2.99
	web-sys@0.3.76
	web-time@1.1.0
	webpki-roots@0.26.7
	which@6.0.3
	which@7.0.0
	widestring@1.1.0
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.9
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-core@0.52.0
	windows-core@0.57.0
	windows-implement@0.57.0
	windows-interface@0.57.0
	windows-registry@0.2.0
	windows-result@0.1.2
	windows-result@0.2.0
	windows-strings@0.1.0
	windows-sys@0.48.0
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-targets@0.48.5
	windows-targets@0.52.6
	windows@0.57.0
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.48.5
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.48.5
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.48.5
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.48.5
	windows_x86_64_msvc@0.52.6
	winnow@0.6.20
	winsafe@0.0.19
	write16@1.0.0
	writeable@0.5.5
	x25519-dalek@2.0.1
	xattr@1.3.1
	xx@2.0.3
	xz2@0.1.7
	yansi@1.0.1
	yoke-derive@0.7.5
	yoke@0.7.5
	zerocopy-derive@0.7.35
	zerocopy@0.7.35
	zerofrom-derive@0.1.5
	zerofrom@0.1.5
	zeroize@1.8.1
	zeroize_derive@1.4.2
	zerovec-derive@0.10.3
	zerovec@0.10.4
	zip@2.2.2
	zipsign-api@0.1.2
	zopfli@0.8.1
	zstd-safe@7.2.1
	zstd-sys@2.0.13+zstd.1.5.6
	zstd@0.13.2
"

inherit cargo

DESCRIPTION="The front-end to your dev env"
HOMEPAGE="https://mise.jdx.dev"
SRC_URI="https://github.com/jdx/mise/archive/refs/tags/v${PV}.tar.gz
${CARGO_CRATE_URIS}"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD Boost-1.0 ISC MIT
	MPL-2.0 Unicode-3.0
"
SLOT="0"
KEYWORDS="amd64 arm64 x86"
