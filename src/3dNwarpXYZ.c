#include "mrilib.h"

#ifdef USE_OMP
#include <omp.h>
#endif

#include "mri_genalign_util.c"
#include "mri_genalign.c"
#include "mri_nwarp.c"

/*----------------------------------------------------------------------------*/

void print_usage(void)
{
   printf(
    "Usage: 3dNwarpXYZ [options] -nwarp 'warp specification' XYZfile.1D > Output.1D\n"
    "\n"
    "Transforms the DICOM xyz coordinates in the input XYZfile.1D (3 columns)\n"
    "based on the '-nwarp' specification -- which is as in 3dNwarpApply\n"
    "(e.g., allows inversion, catenation, et cetera).\n"
    "\n"
    "If this warp is the _WARP output from 3dQwarp, then it takes XYZ values\n"
    "from the base dataset and transforms them to the corresponding source\n"
    "dataset location.\n"
    "\n"
    "To do the reverse operation -- to take an XYZ in the source dataset\n"
    "and find out where it goes to in the base dataset -- do one of these:\n"
    "  * use the _WARPINV output from 3dQwarp instead of the _WARP output;\n"
    "  * use the 'INV(dataset)' form for '-nwarp' (will be slow);\n"
    "  * use the '-iwarp' option described below.\n"
    "The first 2 choices should be equivalent.  The third choice will give\n"
    "slightly different results, since the method used for warp inversion\n"
    "for just a few discrete points is very different than the full warp\n"
    "inversion algorithm -- this difference is for speed.\n"
    "\n"
    "The mean Euclidean error between '-iwarp' and _WARPINV is about 0.006 mm\n"
    "in one test.  The largest error (using 1000 random points) in this test\n"
    "was about 0.05 mm.  About 95%% of points had 0.015 mm error or less.\n"
    "For any 3D brain MRI purpose that Zhark can envision, this level of\n"
    "concordance should be adequately good-iful.\n"
    "\n"
    "-------------\n"
    "OTHER OPTIONS (i.e., besides the mandatory '-nwarp')\n"
    "-------------\n"
    " -iwarp    = Compute the inverse warp for each input (x,y,z) triple.\n"
    "\n"
#if 0  /* -wfac does NOT work with -iwarp!!! */
    " -wfac fff = Scale displacments by factor 'fff' before using.\n"
    "             It is hard to see that this has any value, but here it is.\n"
    "\n"
#endif
    "July 2014 - Zhark the Coordinated\n"
   ) ;
#if 0
   PRINT_AFNI_OMP_USAGE("3dNwarpXYZ",NULL) ;
#endif
   PRINT_COMPILE_DATE ; exit(0) ;
}

/*----------------------------------------------------------------------------*/

int main( int argc , char *argv[] )
{
   THD_3dim_dataset *dset_nwarp=NULL ;
   MRI_IMAGE *xyz_in , *xyz_out ;
   int npt , code , iarg , do_inv=0 ;
   float dfac=1.0f ;
   float *xin,*yin,*zin , *xut,*yut,*zut ;

   AFNI_SETUP_OMP(0) ;

   if( argc < 2 || strcasecmp(argv[1],"-help") == 0 ) print_usage() ;

   /**--- bookkeeping and marketing ---**/

   mainENTRY("3dNwarpXYZ"); machdep();
   AFNI_logger("3dNwarpXYZ",argc,argv);
   PRINT_VERSION("3dNwarpXYZ"); AUTHOR("Zhark the Coordinated");
   (void)COX_clock_time() ;
   putenv("AFNI_WSINC5_SILENT=YES") ;

   /**--- process command line options ---**/

   iarg = 1 ;
   while( iarg < argc && argv[iarg][0] == '-' ){

     if( strcasecmp(argv[iarg],"-nwarp") == 0 || strcasecmp(argv[iarg],"-warp") == 0 ){
       if( dset_nwarp != NULL ) ERROR_exit("Can't have multiple %s options :-(",argv[iarg]) ;
       if( ++iarg >= argc ) ERROR_exit("No argument after '%s' :-(",argv[iarg-1]) ;
       dset_nwarp = IW3D_read_catenated_warp( argv[iarg] ) ;  /* the complicated way */
       if( dset_nwarp == NULL ) ERROR_exit("can't open warp dataset '%s' :-(",argv[iarg]);
       if( DSET_NVALS(dset_nwarp) < 3 ) ERROR_exit("dataset '%s' isn't a 3D warp",argv[iarg]);
       iarg++ ; continue ;
     }

     if( strcasecmp(argv[iarg],"-iwarp") == 0 ){
       do_inv = 1 ; iarg++ ; continue ;
     }

#if 0  /*** note that -wfac does not work with -iwarp !!! ***/
     if( strcasecmp(argv[iarg],"-wfac") == 0 ){
       if( ++iarg >= argc ) ERROR_exit("No argument after '%s' :-(",argv[iarg-1]) ;
       dfac = (float)strtod(argv[iarg],NULL) ;
       if( dfac == 0.0f ) dfac = 1.0f ;
       iarg++ ; continue ;
     }
#endif

     ERROR_exit("Unknown, Illegal, and Fattening option '%s' :-( :-( :-(",argv[iarg]) ;
   }

   if( dset_nwarp == NULL )
     ERROR_exit("No -nwarp option?  How do you want to warp? :-(") ;

   if( iarg >= argc )
     ERROR_exit("No 1D file on command line? :-(") ;

   xyz_in = mri_read_1D( argv[iarg] ) ;
   if( xyz_in == NULL )
     ERROR_exit("Can't read 1D file '%s'",argv[iarg]) ;

   if( xyz_in->ny != 3 )
     ERROR_exit("1D file '%s' has %d columns, not the 3 required",argv[iarg],xyz_in->ny) ;

   npt = xyz_in->nx ;
   xin = MRI_FLOAT_PTR(xyz_in) ;
   yin = xin + npt ;
   zin = yin + npt ;

   xyz_out = mri_new( npt , 3 , MRI_float ) ;
   xut = MRI_FLOAT_PTR(xyz_out) ;
   yut = xut + npt ;
   zut = yut + npt ;

   if( do_inv ){
     code = THD_nwarp_inverse_xyz( dset_nwarp ,
                                   dfac,npt , xin,yin,zin , xut,yut,zut ) ;
   } else {
     code = THD_nwarp_forward_xyz( dset_nwarp ,
                                   dfac,npt , xin,yin,zin , xut,yut,zut ) ;
   }

   if( code < 0 )
     ERROR_exit("THD_nwarp_forward_xyz returns error code = %d",code) ;

   mri_write_1D( "stdout:" , xyz_out ) ;
   exit(0) ;
}