/**
 * Componente pasafotos.
 *
 * @author: fer : 12/04/14 - 10:00
 * @extends AbstractComponent
 * @implements IComponent
 */
package components
{

import com.greensock.TweenLite;
import com.greensock.easing.Quad;

import flash.display.DisplayObject;

import flash.display.Sprite;

public class Slideshow extends AbstractComponent implements IComponent
{
    private var images:Array; // array de nombres de imágenes
    private var imageLoader:ImageLoader; // gestor de carga
    private var imageEffect:ImageEffect; // gestor de efectos

    private var image1:Sprite; // contenedor de imagen 1
    private var image2:Sprite; // contenedor de imagen 2
    private var imagesHolder:Sprite; // contenedor de imágenes
    private var frontImage:Sprite = null;

    private var w:Number = 0;
    private var h:Number = 0;

    public function Slideshow()
    {
        super();
        _type = AbstractComponent.SLIDESHOW;

        TweenLite.to(this, 0, {alpha: 0});
    }

    public function init():void
    {
        this.alpha = parseFloat(data.@transparencia);

        w = _area.width * data.@ancho;
        h = _area.height * data.@alto;

        var xPos:Number = _area.width * data.@cX;
        var yPos:Number = _area.height * data.@cY;

        this.x = xPos;
        this.y = yPos;

        var masking:Sprite = new Sprite(); // máscara
        masking.x = 0;
        masking.y = 0;
        masking.graphics.beginFill(0xff0000, .25);
        masking.graphics.drawRect(0,0,w,h);
        masking.graphics.endFill();

        addChild(masking);

        imagesHolder = new Sprite();
        image1 = new Sprite();
        image2 = new Sprite();

        image1.name = "image1";
        image2.name = "image2";

        imagesHolder.mask = masking;

        addChild(imagesHolder);
        imagesHolder.addChild(image2);
        imagesHolder.addChild(image1);

        imageEffect = new ImageEffect(w, h);
        imageEffect.addEventListener(ImageEffectEvent.ON_EFFECT_IN, handle_effectIn, false, 0, true);
        imageEffect.addEventListener(ImageEffectEvent.ON_EFFECT_OUT, handle_effectOut, false, 0, true);
        imageLoader = new ImageLoader();
        imageLoader.addEventListener(ImageLoaderEvent.IMAGE_LOADED, handle_imageLoaded, false, 0, true);
        imageLoader.addEventListener(ImageLoaderEvent.IMAGE_ERROR, handle_imageError, false, 0, true);

        imageEffect.ease = "easeOutBack";
        imageEffect.effectMode = "Ninguno";
        imageEffect.fromTo = "toIzda";
        imageEffect.speed = 1;
        imageEffect.delay = 2;

        imageEffect.ease = data.@efecto;
        imageEffect.effectMode = data.@sentido;
        imageEffect.fromTo = data.@direccion;
        imageEffect.speed = data.@vel_trans;
        imageEffect.delay = data.@tiempo_trans/1000;
        images = (data.@url_imagenes).split(",");
        imageLoader.init(images);

        initSlideShow();
    }

    private function initSlideShow():void
    {
        TweenLite.to(this, .5, {alpha: 1, ease: Quad.easeOut});

        imageLoader.getNext(image1);
        imageLoader.getNext(image2);

        frontImage = image1;
        applyEffect(image1, false);
    }

    /**
     * Al cargar la imagen se añade al sprite y aplicamos el efecto de movimimiento.
     *
     * @param e
     */
    private function handle_imageLoaded(e:ImageLoaderEvent):void
    {
        var sprite:Sprite = e.holder as Sprite;
        var img:DisplayObject = e.image;
        sprite.addChild(img);

        adjustImage(img);

        imageEffect.initSprite(sprite);
    }

    /**
     * Si se produce un error solicitamos la siguiente imagen.
     *
     * @param e
     */
    private function handle_imageError(e:ImageLoaderEvent):void
    {
        imageLoader.getNext(e.holder);
    }

    /**
     * Se ha producido el efecto de entrada.
     *
     * @param e
     */
    private function handle_effectIn(e:ImageEffectEvent):void
    {
        applyEffect(e.sprite, true);
    }

    private function adjustImage(img:DisplayObject):void
    {
        var scale:Number = Math.min(w / img.width,  h / img.height);
        img.scaleX = img.scaleY = scale;

        img.x = (w - img.width) / 2;
        img.y = (h - img.height) / 2;
    }

    /**
    * Se ha producido el efecto de salida.
    *
    * @param e
    */
   private function handle_effectOut(e:ImageEffectEvent):void
   {
       frontImage = e.sprite == image1 ? image2 : image1;
       imageLoader.getNext(frontImage);
       applyEffect(frontImage, false);
   }

    private function applyEffect(target:Sprite, out:Boolean = false):void
    {
        imageEffect.applyEffect(target, out);
    }

    override public function destroy():void
    {
        imageEffect.destroy();
        imageLoader.destroy();

        imageEffect.removeEventListener(ImageEffectEvent.ON_EFFECT_IN, handle_effectIn);
        imageEffect.removeEventListener(ImageEffectEvent.ON_EFFECT_OUT, handle_effectOut);
        imageLoader.removeEventListener(ImageLoaderEvent.IMAGE_LOADED, handle_imageLoaded);
        imageLoader.removeEventListener(ImageLoaderEvent.IMAGE_ERROR, handle_imageError);

        imageEffect = null;
        imageLoader = null;

        while(imagesHolder.numChildren) imagesHolder.removeChildAt(0);
        while(this.numChildren) this.removeChildAt(0);
    }

}
}
