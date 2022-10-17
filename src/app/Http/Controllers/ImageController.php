<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Request;

class ImageController extends Controller
{
    //


    public function index()
    {
        return view('index');
    }

    public function upload(Request $request) 
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);
    
        $image_name = time().'.'.$request->image->extension();  
     
        $path = Storage::disk('s3')->put('static/images', $request->image);
        $s3_path = Storage::disk('s3')->url($path);
        $cloudfront_path = config("app.cloudfront_url").'/'.$path;
        

        // here you need to store image path in database


    
        return redirect()->back()
            ->with('success', 'Image uploaded successfully.')
            ->with('image', $cloudfront_path);

    }
}
