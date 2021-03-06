package audioshoppp.ir.mobile;

import android.os.Build;
import android.os.Bundle;
import android.os.PersistableBundle;

import com.batch.android.Batch;
import com.batch.android.BatchActivityLifecycleHelper;
import com.batch.android.Config;

import java.io.File;
import java.io.IOException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.util.Random;
import java.util.TimeZone;

import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import audioshoppp.ir.mobile.Utilities.MyEncrypter;
import audioshoppp.ir.mobile.Utilities.RandomStringGenerator;
import audioshoppp.ir.mobile.Utilities.Shared;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;


public class MainActivity extends FlutterActivity {
    private final static String PLAYER_CHANNEL = "audioshoppp.ir.mobile/nowplaying";
    private final static String NOTIFICATION_CHANNEL = "audioshoppp.ir.mobile/notification";
    private final static String MAIN_CHANNEL = "audioshoppp.ir.mobile/main";
    String my_key = "21rf23frfgt6yhj8";
    String my_spec_key = "21rf23frfgt6yhj8";

//    @Override
//    public void onCreate(@Nullable Bundle savedInstanceState, @Nullable PersistableBundle persistentState) {
//        super.onCreate(savedInstanceState, persistentState);
//
//        // Batch.setConfig(new Config("608BFC1BC08BD7662DF9A324E7CEC8")); // live
//        Batch.setConfig(new Config("DEV608BFC1BC0CB6EC5DB10AA2B8CE")); // development
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//            registerActivityLifecycleCallbacks(new BatchActivityLifecycleHelper());
//        }
//    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), MAIN_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if(call.method.equals("launchBatch")){
                                Batch.User.editor()
                                        .setAttribute("starshow2705", "StarShow17") // Set an attribute
                                        .save();
                                result.success("OK");
                            }
                        }
                );
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), NOTIFICATION_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getTimeZoneName")) {
                                result.success(TimeZone.getDefault().getID());
                            }
                        }
                );
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), PLAYER_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("decryptFileInJava")) {
//                                result.success("I'm From JAVA");
                                try {
                                    String encryptedFilePath = call.argument("encryptedFilePath");
                                    String[] arrayOfPath = encryptedFilePath.split("/");

                                    String newPath = encryptedFilePath
                                            .replace(arrayOfPath[arrayOfPath.length - 1], "");

                                    String password = Shared.decryptionPassword;
                                    String salt = Shared.decryptionSalt;
                                    String decryptedFileName = RandomStringGenerator.generateString();
                                    IvParameterSpec ivParameterSpec = MyEncrypter.generateIv();
                                    SecretKey key = MyEncrypter.getKeyFromPassword(password, salt);
                                    String algorithm = "AES/CBC/PKCS5Padding";
                                    File inputFile = new File(encryptedFilePath);
                                    File encryptedFile = new File(newPath, "music.encrypted");
                                    File decryptedFile = new File(newPath, decryptedFileName + ".mp3");
                                    //MyEncrypter.encryptFile(algorithm, key, ivParameterSpec, inputFile, encryptedFile);
                                    MyEncrypter.decryptFile(
                                            algorithm, key, ivParameterSpec, inputFile, decryptedFile);

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
