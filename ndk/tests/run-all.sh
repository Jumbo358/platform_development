# Run all tests

PROGDIR=`dirname $0`
PROGDIR=`cd $PROGDIR && pwd`
#
# Sanity checks:
#
if [ -z "$NDK" ] ; then
    echo "ERROR: Please define NDK in your environment to point to the root of your NDK install."
    exit 1
fi

if [ ! -d "$NDK" ] ; then
    echo "ERROR: Your NDK variable does not point to a directory: $NDK"
    exit 2
fi

if [ ! -f "$NDK/ndk-build" -o ! -f "$NDK/build/core/ndk-common.sh" ] ; then
    echo "ERROR: Your NDK variable does not point to a valid NDK directory: $NDK"
    exit 3
fi

#
# Parse options
#
JOBS=
while [ -n "$1" ]; do
    opt="$1"
    optarg=`expr "x$opt" : 'x[^=]*=\(.*\)'`
    case "$opt" in
        --help|-h|-\?)
            OPTION_HELP=yes
            ;;
        --verbose)
            VERBOSE=yes
            ;;
        -j*)
            JOBS="$opt"
            shift
            ;;
        --jobs=*)
            JOBS="-j$optarg"
            ;;
        -*) # unknown options
            echo "ERROR: Unknown option '$opt', use --help for list of valid ones."
            exit 1
        ;;
        *)  # Simply record parameter
            if [ -z "$PARAMETERS" ] ; then
                PARAMETERS="$opt"
            else
                PARAMETERS="$PARAMETERS $opt"
            fi
            ;;
    esac
    shift
done

if [ "$OPTION_HELP" = "yes" ] ; then
    echo "Usage: $PROGNAME [options]"
    echo ""
    echo "Run all NDK automated tests at once."
    echo ""
    echo "Valid options:"
    echo ""
    echo "    --help|-h|-?      Print this help"
    echo "    --verbose         Enable verbose mode"
    echo "    -j<N> --jobs=<N>  Launch parallel builds"
    echo ""
    exit 0
fi

#
# Create log file
#
MYLOG=/tmp/ndk-tests.log
mkdir -p `dirname $MYLOG`
rm -f $MYLOG
echo "NDK automated tests log file" > $MYLOG


#
# Rebuild all samples first
#
build_sample ()
{
    echo "Building NDK sample: $1"
    cd $PROGDIR/../samples/$1
    $NDK/ndk-build -B $JOBS >> $MYLOG 2>&1
    if [ $? != 0 ] ; then
        echo "!!! BUILD FAILURE !!!"
        exit 1
    fi
}

for SAMPLE in `ls $PROGDIR/../samples`; do
    build_sample `basename $SAMPLE`
done
