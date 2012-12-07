#------------------------------------------------------------------------------
# File:         ExifTool_config  -->  ~/.ExifTool_config
#
# Description:  Sample user configuration file for Image::ExifTool
#
# Notes:        This example file shows how to define your own shortcuts and
#               add new EXIF, IPTC, XMP, PNG, MIE and Composite tags, as well
#               as how to specify preferred lenses for the LensID tag and
#               define default values for ExifTool options.
#
#               Note that unknown tags may be extracted even if they aren't
#               defined, but tags must be defined to be written.  Also note
#               that it is possible to override an existing tag definition
#               with a new tag.
#
#               To activate this file, rename it to ".ExifTool_config" and
#               place it in your home directory or the exiftool application
#               directory.  This causes ExifTool to automatically load the file
#               when run.  Your home directory is determined by the first
#               defined of the following environment variables:
#
#                   1. EXIFTOOL_HOME
#                   2. HOME
#                   3. HOMEDRIVE + HOMEPATH
#                   4. (the current directory)
#
#               Alternatively, the -config option of the exiftool application
#               may be used to load a specific configuration file (note that
#               it must be the first option on the command line):
#
#                   exiftool -config ExifTool_config ...
#
#               This sample file defines the following 13 new tags as well as a
#               number of Shortcut and Composite tags:
#
#                   1.  EXIF:NewEXIFTag
#                   2.  IPTC:NewIPTCTag
#                   3.  XMP-xmp:NewXMPxmpTag
#                   4.  XMP-xxx:NewXMPxxxTag1
#                   5.  XMP-xxx:NewXMPxxxTag2
#                   6.  XMP-xxx:NewXMPxxxTag3
#                   7.  XMP-xxx:NewXMPxxxStructX
#                   8.  XMP-xxx:NewXMPxxxStructY
#                   9.  PNG:NewPngTag1
#                  10.  PNG:NewPngTag2
#                  11.  PNG:NewPngTag3
#                  12.  MIE-Meta:NewMieTag1
#                  13.  MIE-Test:NewMieTag2
#
#               For detailed information on the definition of tag tables and
#               tag information hashes, see lib/Image/ExifTool/README.
#------------------------------------------------------------------------------

# Shortcut tags are used when extracting information to simplify
# commonly used commands.  They can be used to represent groups
# of tags, or to provide an alias for a tag name.

# %Image::ExifTool::UserDefined::Shortcuts = (
#     MyShortcut => ['exif:createdate','exposuretime','aperture'],
#     MyAlias => 'FocalLengthIn35mmFormat',
# );

# NOTE: All tag names used in the following tables are case sensitive.

# The %Image::ExifTool::UserDefined hash defines new tags to be added
# to existing tables.
%Image::ExifTool::UserDefined = (
    # new XMP namespaces (ie. xxx) must be added to the Main XMP table:
    'Image::ExifTool::XMP::Main' => {
        madek => {
            SubDirectory => {
                TagTable => 'Image::ExifTool::UserDefined::madek',
                # (see the definition of this table below)
            },
        },
    },
);

# This is a basic example of the definition for a new XMP namespace.
# This table is referenced through a SubDirectory tag definition
# in the %Image::ExifTool::UserDefined definition above.
# The namespace prefix for these tags is 'xxx', which corresponds to
# an ExifTool family 1 group name of 'XMP-xxx'.
%Image::ExifTool::UserDefined::madek = (
    GROUPS => { 0 => 'XMP', 1 => 'XMP-madek', 2 => 'Image' },
    NAMESPACE => { 'madek' => 'http://madek.zhdk.ch/madek/1.0/' },
    WRITABLE => 'string',
    # replace "NewXMPxxxTag1" with your own tag name (ie. "MyTag")
	AcademicYear => { },
	AdditionalAuthors => { List => 'Bag' },
	Album => { },
	Aperture => { },
	Artist => { },
	AudioAttributes => { },
	AudioAvgBitrate => { },
	AudioBitrate => { },
	AudioBitsPerSample => { },
	AudioChannels => { },
	AudioCodec => { },
	AudioCodecInfo => { },
	AudioEncoding => { },
	AudioFormat => { },
	AudioGain => { },
	AudioLayer => { },
	AudioMaxBitrate => { },
	AudioProfileVersion => { },
	AudioSampleCount => { },
	AudioSampleRate => { },
	AudioTrackID => { },
	Author => { },
	AuthorsPosition => { },
	AvgBitrate => { },
	AvgBytesPerSec => { },
	Balance => { },
	Bass => { },
	BeatsPerMinute => { },
	BitDepth => { },
	BitsPerSample => { },
	Brightness => { },
	ByteLength => { },
	CameraIdentifier => { },
	CanSeekOnTime => { },
	CanonFlashInfo => { },
	CanonFlashMode => { },
	CaptionWriter => { },
	Category => { },
	ChannelMode => { },
	ChapterList => { },
	ChunkOffset => { },
	ChunkOffset64 => { },
	City => { },
	Color => { },
	ColorMode => { },
	ComAppleFinalcutstudioMediaHistoryUuid => { },
	ComAppleFinalcutstudioMediaUuid => { },
	ComAppleProappsClipID => { },
	ComAppleProappsIsGood => { },
	ComAppleProappsOriginalFormat => { },
	ComAppleProappsReel => { },
	ComSonyBprlMxfUmid => { },
	ComSonyBprlXdcamradplugVersion => { },
	ComSonyProfessionaldiscNonrealtimemetaLastupdate => { },
	Comment => { },
	CompatibleBrands => { },
	Composer => { },
	CompositionTimeToSample => { },
	CompositionToDecodeTimelineMapping => { },
	CompressorID => { },
	CompressorName => { },
	CompressorVersion => { },
	Contrast => { },
	CopyrightFlag => { },
	Country => { },
	CountryCode => { },
	Coverage => { },
	CreateDate => { },
	CreateDate-deu => { },
	CreationDate-deu => { },
	Creator => { },
	CreatorAddress => { },
	CreatorCity => { },
	CreatorContactInfo => { },
	CreatorCountry => { },
	CreatorPostalCode => { },
	CreatorRegion => { },
	CreatorWorkEmail => { },
	CreatorWorkTelephone => { },
	CreatorWorkURL => { },
	Credit => { },
	CurrentTime => { },
	Date => { },
	DateCreated => { },
	DateTimeOriginal => { },
	Description => { },
	DocumentAncestors => { },
	DriveMode => { },
	Duration => { },
	Emphasis => { },
	EncodedBy => { },
	Encoder => { },
	EncoderSettings => { },
	Encoding => { },
	EncodingTime => { },
	FileFunctionFlags => { },
	FileProfileVersion => { },
	FirmwareVersion => { },
	Flash => { },
	FlashActivity => { },
	FlashBits => { },
	FlashExposureComp => { },
	FlashGuideNumber => { },
	FlashOutput => { },
	FlashpixVersion => { },
	FocalLength35efl => { },
	Format => { },
	FrameCount => { },
	FrameRate => { },
	FrameReadoutTime => { },
	Free => { },
	GPSCoordinates-deu => { },
	GenBalance => { },
	GenFlags => { },
	GenGraphicsMode => { },
	GenMediaVersion => { },
	GenOpColor => { },
	Genre => { },
	GraphicsMode => { },
	HTTPHostHeader => { },
	HandlerClass => { },
	HandlerDescription => { },
	HandlerType => { },
	HandlerVendorID => { },
	Headline => { },
	History => { },
	Hyperlinks => { },
	ID3Size => { },
	Identifier => { },
	IdependentAndDisposableSamples => { },
	ImageHeight => { },
	ImageSize => { },
	ImageWidth => { },
	InitialObjectDescriptor => { },
	InstitutionalAffiliation => { },
	Instructions => { },
	IntellectualGenre => { },
	IntensityStereo => { },
	LameBitrate => { },
	LameLowPassFilter => { },
	LameMethod => { },
	LameQuality => { },
	LameStereoMode => { },
	LameVBRQuality => { },
	Language => { },
	Lens => { },
	Lens35efl => { },
	LensID => { },
	LensSpec => { },
	Location => { },
	MPEGAudioVersion => { },
	MSStereo => { },
	MajorBrand => { },
	Make-deu => { },
	ManualFlashOutput => { },
	Marked => { },
	MatrixStructure => { },
	MaxDataRate => { },
	MediaCreateDate => { },
	MediaDuration => { },
	MediaHeaderVersion => { },
	MediaLanguageCode => { },
	MediaModifyDate => { },
	MediaTimeScale => { },
	Message => { },
	MinorVersion => { },
	Model-deu => { },
	ModifyDate => { },
	MovieData => { },
	MovieDataSize => { },
	MovieHeaderVersion => { },
	Mute => { },
	Name => { },
	NextTrackID => { },
	NullMediaHeader => { },
	NumChannels => { },
	OpColor => { },
	OrgSmpteMxfPackageMaterialPackageid => { },
	OriginalMedia => { },
	OtherCreativeParticipants => { },
	OtherFormat => { },
	PantryFlashFired => { },
	PantryFlashFunction => { },
	PantryFlashMode => { },
	PantryFlashRedEyeMode => { },
	PantryFlashReturn => { },
	ParticipatingInstitution => { },
	Picture => { },
	PictureDescription => { },
	PictureFormat => { },
	PictureType => { },
	PitchShift => { },
	PixelAspectRatio => { },
	PlayAllFrames => { },
	PlaySelection => { },
	PlayerVersion => { },
	PortrayedInstitution => { },
	PortrayedObjectDates => { },
	PortrayedObjectDimensions => { },
	PortrayedObjectMaterials => { },
	PortrayedPerson => { },
	PosterTime => { },
	PreferredRate => { },
	PreferredVolume => { },
	PreviewDuration => { },
	PreviewTime => { },
	ProjectLeader => { },
	ProjectType => { },
	PublicCaption => { },
	Publisher => { },
	Quality => { },
	Rating => { },
	Relation => { },
	ReleaseTime => { },
	Remark => { },
	Requirements => { },
	Rights => { },
	Rotation => { },
	SampleRate => { },
	SampleSize => { },
	SampleSizes => { },
	SampleToChunk => { },
	Scene => { },
	SelectionDuration => { },
	SelectionTime => { },
	ShootingMode => { },
	ShortDescription => { },
	ShutterSpeed => { },
	SidecarForExtension => { },
	Software => { },
	Software-deu => { },
	SoftwareVersion-deu => { },
	Source => { },
	SourceCredits => { },
	SourceData => { },
	SourceImage => { },
	SourceImageHeight => { },
	SourceImageWidth => { },
	SourceIsbn => { },
	SourcePlate => { },
	SourceSide => { },
	StartTime => { },
	State => { },
	StreamCount => { },
	StreamType => { },
	Subject => { List => 'Bag' },
	SubjectCode => { },
	SupplementalCategories => { },
	SyncSampleTable => { },
	Tags => { },
	Text => { },
	TextJunk => { },
	TextLayerName => { },
	TextLayerText => { },
	Time => { },
	TimeScale => { },
	TimeToSampleTable => { },
	Tint => { },
	Title => { },
	TotalDataRate => { },
	TotalDuration => { },
	TotalFrameCount => { },
	Track => { },
	TrackCreateDate => { },
	TrackDuration => { },
	TrackHeaderVersion => { },
	TrackID => { },
	TrackLayer => { },
	TrackModifyDate => { },
	TrackNumber => { },
	TrackProperty => { },
	TrackVolume => { },
	TransmissionReference => { },
	Trebel => { },
	Type => { },
	URL => { },
	Unknown_0x009b => { },
	Unknown_0x010a => { },
	Unknown_CNDB => { },
	Unknown_CNDM => { },
	Unknown_Cr8r => { },
	Unknown_FIEL => { },
	Unknown_FXTC => { },
	Unknown_aeLK => { },
	Unknown_alis => { },
	Unknown_apmd => { },
	Unknown_cios => { },
	Unknown_edts => { },
	Unknown_free => { },
	Unknown_gshh => { },
	Unknown_gspm => { },
	Unknown_gspu => { },
	Unknown_gssd => { },
	Unknown_gsst => { },
	Unknown_gstd => { },
	Unknown_kgcg => { },
	Unknown_kgit => { },
	Unknown_kgsi => { },
	Unknown_kgtt => { },
	Unknown_load => { },
	Unknown_mvex => { },
	Unknown_rmra => { },
	Unknown_stps => { },
	Unknown_tapt => { },
	Unknown_tmcd => { },
	Urgency => { },
	Urn => { },
	UsageTerms => { },
	UserData_PRD => { },
	UserData_TIM => { },
	UserData_TSC => { },
	UserData_TSZ => { },
	UserData_enc => { },
	UserData_key => { },
	UserDefinedText => { },
	VBRBytes => { },
	VBRFrames => { },
	VendorID => { },
	Version => { },
	VideoAttributes => { },
	VideoAvgBitrate => { },
	VideoAvgFrameRate => { },
	VideoBitrate => { },
	VideoCodec => { },
	VideoCodecInfo => { },
	VideoEncoding => { },
	VideoFrameCount => { },
	VideoFrameRate => { },
	VideoMaxBitrate => { },
	VideoMaxFrameRate => { },
	VideoProfileVersion => { },
	VideoSize => { },
	VideoTrackID => { },
	WebStatement => { },
	Wide => { },
	WindowLocation => { },
	XResolution => { },
	YResolution => { },
	Year => { },
	patron => { },
    # XMP structures are defined as SubDirectory's
    XMPmadekStruct => {
        SubDirectory => { },  # treat as a subdirectory containing other tags
        Struct => 'MadekStruct', # arbitrary name identifies entry in xmpStruct
        List => 'Seq',        # structures may also be elements of a list
    },
    # structure elements must be defined as separate tags.  The tag ID's
    # are the concatination of the structure tag ID with the ID of each
    # structure element in turn.  The list flag should be set if the
    # parent structure is contained in a list.
    XMPmadekStructX => { List => 1 },
    XMPmadekStructY => { List => 1 },
);

# User-defined XMP structures are added to the xmpStruct lookup
%Image::ExifTool::UserDefined::xmpStruct = (
    # A structure with 2 elements: X and Y
    MadekStruct => {
        NAMESPACE => { 'test' => 'http://madek.zhdk.ch/test/' },
        # TYPE is optional -- it adds an rdf:type element to the structure
        TYPE => 'http://madek.zhdk.ch/test/madekstruct',
        X => { },
        Y => { },
    },
);


# Specify default ExifTool option values
# (see the Options function documentation for available options)
%Image::ExifTool::UserDefined::Options = (
    CoordFormat => '%.6f',  # change default GPS coordinate format
    Duplicates => 1,        # make -a default for the exiftool app
    GeoMaxHDOP => 4,        # ignore GPS fixes with HDOP > 4
);

#------------------------------------------------------------------------------
1;  #end
