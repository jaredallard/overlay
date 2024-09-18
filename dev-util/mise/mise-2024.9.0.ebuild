# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Autogenerated by pycargoebuild 0.13.2

EAPI=8

CRATES="
	addr2line@0.21.0
	adler2@2.0.0
	adler@1.0.2
	aes@0.8.4
	ahash@0.8.11
	aho-corasick@1.1.3
	android-tzdata@0.1.1
	android_system_properties@0.1.5
	ansi-str@0.8.0
	ansitok@0.2.0
	anstream@0.6.15
	anstyle-parse@0.2.5
	anstyle-query@1.1.1
	anstyle-wincon@3.0.4
	anstyle@1.0.8
	arbitrary@1.3.2
	arrayvec@0.5.2
	assert_cmd@2.0.16
	async-compression@0.4.12
	atomic-waker@1.1.2
	autocfg@1.3.0
	backtrace@0.3.71
	base64@0.22.1
	base64ct@1.6.0
	bitflags@1.3.2
	bitflags@2.6.0
	block-buffer@0.10.4
	bstr@1.10.0
	built@0.7.4
	bumpalo@3.16.0
	bytecount@0.6.8
	byteorder@1.5.0
	bytes@1.7.1
	bzip2-sys@0.1.11+1.0.8
	bzip2@0.4.4
	calm_io@0.1.1
	calmio_filters@0.1.0
	cc@1.1.16
	cfg-if@1.0.0
	cfg_aliases@0.2.1
	chrono-tz-build@0.3.0
	chrono-tz@0.9.0
	chrono@0.4.38
	ci_info@0.14.14
	cipher@0.4.4
	clap@4.5.17
	clap_builder@4.5.17
	clap_derive@4.5.13
	clap_lex@0.7.2
	clap_mangen@0.2.23
	color-eyre@0.6.3
	color-print-proc-macro@0.3.6
	color-print@0.3.6
	color-spantrace@0.2.1
	colorchoice@1.0.2
	confique-macro@0.0.9
	confique@0.2.5
	console@0.15.8
	const-oid@0.9.6
	constant_time_eq@0.3.1
	contracts@0.6.3
	core-foundation-sys@0.8.7
	core-foundation@0.9.4
	cpufeatures@0.2.13
	crc-catalog@2.4.0
	crc32fast@1.4.2
	crc@3.2.1
	crossbeam-deque@0.8.5
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.20
	crypto-common@0.1.6
	cssparser-macros@0.6.1
	cssparser@0.31.2
	ctor@0.2.8
	curve25519-dalek-derive@0.1.1
	curve25519-dalek@4.1.3
	deflate64@0.1.9
	demand@1.2.4
	der@0.7.9
	deranged@0.3.11
	derive_arbitrary@1.3.2
	derive_more@0.99.18
	deunicode@1.6.0
	diff@0.1.13
	difflib@0.4.0
	digest@0.10.7
	displaydoc@0.2.5
	doc-comment@0.3.3
	dotenvy@0.15.7
	dtoa-short@0.3.5
	dtoa@1.0.9
	duct@0.13.7
	dunce@1.0.5
	ed25519-dalek@2.1.1
	ed25519@2.2.3
	ego-tree@0.6.3
	either@1.13.0
	encode_unicode@0.3.6
	encoding_rs@0.8.34
	env_filter@0.1.2
	env_logger@0.11.5
	envmnt@0.10.4
	equivalent@1.0.1
	erased-serde@0.4.5
	errno-dragonfly@0.1.2
	errno@0.2.8
	errno@0.3.9
	exec@0.3.1
	eyre@0.6.12
	fastrand@2.1.1
	fiat-crypto@0.2.9
	filetime@0.2.25
	fixedbitset@0.4.2
	flate2@1.0.33
	float-cmp@0.9.0
	fnv@1.0.7
	foreign-types-shared@0.1.1
	foreign-types@0.3.2
	form_urlencoded@1.2.1
	fsio@0.4.0
	fslock@0.2.1
	futf@0.1.5
	futures-channel@0.3.30
	futures-core@0.3.30
	futures-io@0.3.30
	futures-sink@0.3.30
	futures-task@0.3.30
	futures-util@0.3.30
	fxhash@0.2.1
	generic-array@0.14.7
	getopts@0.2.21
	getrandom@0.2.15
	gimli@0.28.1
	git2@0.19.0
	glob@0.3.1
	globset@0.4.14
	globwalk@0.9.1
	h2@0.4.6
	hashbrown@0.12.3
	hashbrown@0.14.5
	heck@0.3.3
	heck@0.4.1
	heck@0.5.0
	hermit-abi@0.3.9
	hmac@0.12.1
	home@0.5.9
	homedir@0.3.3
	html5ever@0.27.0
	http-body-util@0.1.2
	http-body@1.0.1
	http@1.1.0
	httparse@1.9.4
	humansize@2.1.3
	humantime@2.1.0
	hyper-rustls@0.27.3
	hyper-tls@0.6.0
	hyper-util@0.1.7
	hyper@1.4.1
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.60
	idna@0.5.0
	ignore@0.4.22
	indenter@0.3.3
	indexmap@1.9.3
	indexmap@2.5.0
	indicatif@0.17.8
	indoc@2.0.5
	inout@0.1.3
	insta@1.39.0
	instant@0.1.13
	ipnet@2.9.0
	is_terminal_polyfill@1.70.1
	itertools@0.12.1
	itertools@0.13.0
	itoa@1.0.11
	jobserver@0.1.32
	js-sys@0.3.70
	kdl@4.6.0
	lazy_static@1.5.0
	libc@0.2.158
	libgit2-sys@0.17.0+1.8.1
	libm@0.2.8
	libredox@0.1.3
	libssh2-sys@0.3.0
	libz-sys@1.1.20
	linked-hash-map@0.5.6
	linux-raw-sys@0.4.14
	lock_api@0.4.12
	lockfree-object-pool@0.1.6
	log@0.4.22
	lua-src@547.0.0
	luajit-src@210.5.10+f725e44
	lzma-rs@0.3.0
	lzma-sys@0.1.20
	mac@0.1.1
	markup5ever@0.12.1
	matchers@0.1.0
	memchr@2.7.4
	memoffset@0.7.1
	miette-derive@5.10.0
	miette@5.10.0
	mime@0.3.17
	minimal-lexical@0.2.1
	miniz_oxide@0.7.4
	miniz_oxide@0.8.0
	mio@1.0.2
	mlua-sys@0.6.2
	mlua@0.9.9
	mlua_derive@0.9.3
	native-tls@0.2.12
	new_debug_unreachable@1.0.6
	nix@0.26.4
	nix@0.29.0
	nom@7.1.3
	normalize-line-endings@0.3.0
	nu-ansi-term@0.46.0
	num-conv@0.1.0
	num-traits@0.2.19
	num_cpus@1.16.0
	num_threads@0.1.7
	number_prefix@0.4.0
	object@0.32.2
	once_cell@1.19.0
	openssl-macros@0.1.1
	openssl-probe@0.1.5
	openssl-sys@0.9.103
	openssl@0.10.66
	ordered-float@2.10.1
	os_pipe@1.2.1
	overload@0.1.1
	owo-colors@3.5.0
	papergrid@0.12.0
	parking_lot@0.12.3
	parking_lot_core@0.9.10
	parse-zoneinfo@0.3.1
	paste@1.0.15
	path-absolutize@3.1.1
	path-dedot@3.1.1
	pbkdf2@0.12.2
	percent-encoding@2.3.1
	pest@2.7.11
	pest_derive@2.7.11
	pest_generator@2.7.11
	pest_meta@2.7.11
	petgraph@0.6.5
	phf@0.10.1
	phf@0.11.2
	phf_codegen@0.10.0
	phf_codegen@0.11.2
	phf_generator@0.10.0
	phf_generator@0.11.2
	phf_macros@0.11.2
	phf_shared@0.10.0
	phf_shared@0.11.2
	pin-project-internal@1.1.5
	pin-project-lite@0.2.14
	pin-project@1.1.5
	pin-utils@0.1.0
	pkcs8@0.10.2
	pkg-config@0.3.30
	portable-atomic@1.7.0
	powerfmt@0.2.0
	ppv-lite86@0.2.20
	precomputed-hash@0.1.1
	predicates-core@1.0.8
	predicates-tree@1.0.11
	predicates@3.1.2
	pretty_assertions@1.4.0
	proc-macro-error-attr@1.0.4
	proc-macro-error@1.0.4
	proc-macro2@1.0.86
	quick-xml@0.23.1
	quinn-proto@0.11.8
	quinn-udp@0.5.5
	quinn@0.11.5
	quote@1.0.37
	rand@0.8.5
	rand_chacha@0.3.1
	rand_core@0.6.4
	rayon-core@1.12.1
	rayon@1.10.0
	redox_syscall@0.5.3
	regex-automata@0.1.10
	regex-automata@0.4.7
	regex-syntax@0.6.29
	regex-syntax@0.8.4
	regex@1.10.6
	reqwest@0.12.7
	ring@0.17.8
	rmp-serde@1.3.0
	rmp@0.8.14
	roff@0.2.2
	rustc-demangle@0.1.24
	rustc-hash@2.0.0
	rustc_version@0.4.1
	rustix@0.38.35
	rustls-native-certs@0.7.3
	rustls-native-certs@0.8.0
	rustls-pemfile@2.1.3
	rustls-pki-types@1.8.0
	rustls-webpki@0.102.7
	rustls@0.23.12
	rustversion@1.0.17
	ryu@1.0.18
	same-file@1.0.6
	schannel@0.1.23
	scopeguard@1.2.0
	scraper@0.20.0
	security-framework-sys@2.11.1
	security-framework@2.11.1
	selectors@0.25.0
	self-replace@1.5.0
	self_update@0.41.0
	semver@1.0.23
	serde-value@0.7.0
	serde@1.0.209
	serde_derive@1.0.209
	serde_ignored@0.1.10
	serde_json@1.0.128
	serde_spanned@0.6.7
	serde_urlencoded@0.7.1
	servo_arc@0.3.0
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
	simplelog@0.12.2
	siphasher@0.3.11
	siphasher@1.0.1
	slab@0.4.9
	slug@0.1.6
	smallvec@1.13.2
	socket2@0.5.7
	spin@0.9.8
	spki@0.7.3
	stable_deref_trait@1.2.0
	string_cache@0.8.7
	string_cache_codegen@0.5.2
	strsim@0.11.1
	strum@0.26.3
	strum_macros@0.26.4
	subtle@2.6.1
	syn@1.0.109
	syn@2.0.77
	sync_wrapper@1.0.1
	sys-info@0.9.1
	system-configuration-sys@0.6.0
	system-configuration@0.6.1
	tabled@0.16.0
	tabled_derive@0.8.0
	tar@0.4.41
	tempfile@3.12.0
	tendril@0.4.3
	tera@1.20.0
	termcolor@1.4.1
	terminal_size@0.3.0
	termtree@0.4.1
	test-case-core@3.3.1
	test-case-macros@3.3.1
	test-case@3.3.1
	test-log-macros@0.2.16
	test-log@0.2.16
	thiserror-impl@1.0.63
	thiserror@1.0.63
	thread_local@1.1.8
	time-core@0.1.2
	time-macros@0.2.18
	time@0.3.36
	tinyvec@1.8.0
	tinyvec_macros@0.1.1
	tokio-macros@2.4.0
	tokio-native-tls@0.3.1
	tokio-rustls@0.26.0
	tokio-util@0.7.12
	tokio@1.40.0
	toml@0.8.19
	toml_datetime@0.6.8
	toml_edit@0.22.20
	tower-layer@0.3.3
	tower-service@0.3.3
	tower@0.4.13
	tracing-core@0.1.32
	tracing-error@0.2.0
	tracing-log@0.2.0
	tracing-subscriber@0.3.18
	tracing@0.1.40
	try-lock@0.2.5
	typeid@1.0.2
	typenum@1.17.0
	ucd-trie@0.1.6
	unic-char-property@0.9.0
	unic-char-range@0.9.0
	unic-common@0.9.0
	unic-segment@0.9.0
	unic-ucd-segment@0.9.0
	unic-ucd-version@0.9.0
	unicode-bidi@0.3.15
	unicode-ident@1.0.12
	unicode-normalization@0.1.23
	unicode-segmentation@1.11.0
	unicode-width@0.1.11
	untrusted@0.9.0
	url@2.5.2
	urlencoding@2.1.3
	usage-lib@0.3.1
	utf-8@0.7.6
	utf8parse@0.2.2
	valuable@0.1.0
	vcpkg@0.2.15
	version_check@0.9.5
	versions@6.3.2
	vfox@0.1.3
	vte@0.10.1
	vte_generate_state_changes@0.1.2
	wait-timeout@0.2.0
	walkdir@2.5.0
	want@0.3.1
	wasi@0.11.0+wasi-snapshot-preview1
	wasm-bindgen-backend@0.2.93
	wasm-bindgen-futures@0.4.43
	wasm-bindgen-macro-support@0.2.93
	wasm-bindgen-macro@0.2.93
	wasm-bindgen-shared@0.2.93
	wasm-bindgen@0.2.93
	web-sys@0.3.70
	webpki-roots@0.26.5
	which@6.0.3
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
	winnow@0.6.18
	winsafe@0.0.19
	xattr@1.3.1
	xx@1.1.8
	xz2@0.1.7
	yansi@0.5.1
	zerocopy-derive@0.7.35
	zerocopy@0.7.35
	zeroize@1.8.1
	zeroize_derive@1.4.2
	zip@2.2.0
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
	MPL-2.0 Unicode-DFS-2016
"
SLOT="0"
KEYWORDS="amd64 arm64 x86"