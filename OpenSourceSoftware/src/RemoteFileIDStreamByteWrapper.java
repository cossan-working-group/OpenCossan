import java.io.*;
import ch.ethz.ssh2.*;

/*********************************************************************

Compile from within Matlab with:
!javac -classpath <opensource_software_dir>/dist/ganymed-ssh2-261.jar InputStreamByteWrapper.java

For reason of compatibility with Matlab, this class MUST be compiled
with the Sun/Oracle java 1.6 (no Oracle java 1.7, no gcj, no OpenJDK
is supported by Matlab!)

*********************************************************************/
public class RemoteFileIDStreamByteWrapper {
  public static byte[] bfr = null;
  SFTPv3Client SFTPclient = null;

  public RemoteFileIDStreamByteWrapper(SFTPv3Client client) {
    this(client, 4096);
  }

  public RemoteFileIDStreamByteWrapper(SFTPv3Client client, int capacity) {
    bfr = new byte[capacity];
    SFTPclient = client;
  }

  public int readBuffer(SFTPv3FileHandle in, long offset, int length) throws
IOException {
    return SFTPclient.read(in, offset, bfr, 0, length);
  }

  public int readBuffer(SFTPv3FileHandle in, int length) throws IOException {
    return readBuffer(in, 0, length);
  }
}
