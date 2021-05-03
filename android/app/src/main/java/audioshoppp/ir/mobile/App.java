package audioshoppp.ir.mobile;

import android.app.Application;

import com.batch.android.Batch;
import com.batch.android.BatchActivityLifecycleHelper;
import com.batch.android.Config;

import androidx.annotation.CallSuper;
import io.flutter.app.FlutterApplication;

public class App extends FlutterApplication
{
    @Override
    @CallSuper
    public void onCreate()
    {
        super.onCreate();

         Batch.setConfig(new Config("60831FA19C5900A9AC92D5F49B920C")); // live
//        Batch.setConfig(new Config("DEV60831FA19CB55DF09E357A4475C")); // development
        registerActivityLifecycleCallbacks(new BatchActivityLifecycleHelper());
        // You should configure your notification's customization options here.
        // Not setting up a small icon could cause a crash in applications created with Android Studio 3.0 or higher.
        // More info in our "Customizing Notifications" documentation
        // Batch.Push.setSmallIconResourceId(R.drawable.ic_notification_icon);
    }
}
