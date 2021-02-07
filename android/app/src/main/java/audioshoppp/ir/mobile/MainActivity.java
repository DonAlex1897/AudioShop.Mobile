package audioshoppp.ir.mobile;

import android.widget.Toast;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.util.Random;

import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;

import androidx.annotation.NonNull;
import audioshoppp.ir.mobile.Utilities.MyEncrypter;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;


public class MainActivity extends FlutterActivity {
    private final static  String CHANNEL = "audioshoppp.ir.mobile/nowplaying";
    String my_key = "21rf23frfgt6yhj8";
    String my_spec_key = "21rf23frfgt6yhj8";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if(call.method.equals("decryptFileInJava")){
//                                result.success("I'm From JAVA");
                                try {
                                    String encryptedFilePath = call.argument("encryptedFilePath");
                                    String[] arrayOfPath = encryptedFilePath.split("/");

                                    String newPath = encryptedFilePath
                                            .replace(arrayOfPath[arrayOfPath.length - 1],"");

                                    String password = "1qaz2wsx";
                                    String salt = "12345678";
                                    IvParameterSpec ivParameterSpec = MyEncrypter.generateIv();
                                    SecretKey key = MyEncrypter.getKeyFromPassword(password,salt);
                                    String algorithm = "AES/CBC/PKCS5Padding";
                                    File inputFile = new File(encryptedFilePath);
                                    File encryptedFile = new File(newPath, "music.encrypted");
                                    File decryptedFile = new File(newPath, "music.decrypted");
                                    MyEncrypter.encryptFile(algorithm, key, ivParameterSpec, inputFile, encryptedFile);
                                    MyEncrypter.decryptFile(
                                            algorithm, key, ivParameterSpec, encryptedFile, decryptedFile);

                                    result.success(decryptedFile.getPath());
                                } catch (NoSuchPaddingException | NoSuchAlgorithmException | InvalidAlgorithmParameterException | InvalidKeyException | IOException e) {
                                    e.printStackTrace();
                                } catch (InvalidKeySpecException e) {
                                    e.printStackTrace();
                                } catch (BadPaddingException e) {
                                    e.printStackTrace();
                                } catch (IllegalBlockSizeException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                );
    }
}
